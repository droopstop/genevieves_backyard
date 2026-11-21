/* Optional desktop checks: install brs@0.45.0 and expose it through NODE_PATH.
 * The renderer uses recorded bitmap/rectangle calls rather than a Roku screen.
 */
const fs = require('fs');
const os = require('os');
const path = require('path');
const { PassThrough } = require('stream');
const brs = require('brs');
const root = path.resolve(__dirname, '..');
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'backyard-check-'));

async function main() {
    const sources = fs.readdirSync(path.join(root, 'source'))
        .filter(name => name.endsWith('.brs'))
        .map(name => path.join(root, 'source', name));
    for (const file of sources) {
        const scanned = brs.lexer.Lexer.scan(fs.readFileSync(file, 'utf8'));
        const parsed = brs.parser.Parser.parse(scanned.tokens);
        if (scanned.errors.length || parsed.errors.length) {
            throw new Error(`${file}: ${[...scanned.errors, ...parsed.errors].map(e => e.message).join('; ')}`);
        }
    }
    console.log(`PASS: ${sources.length} game source files parse`);
    // brs 0.45 lacks Roku's Tokenize. Test strings use single spaces, for which
    // Split produces the same words. The production source stays unchanged.
    const source = sources.map(file => fs.readFileSync(file, 'utf8')).join('\n')
        .replace('sub Main()', 'sub GameMain()')
        .replaceAll('.Tokenize(" ")', '.Split(" ")');
    const functions = path.join(scratch, 'functions.brs');
    fs.writeFileSync(functions, source);
    const helper = path.join(scratch, 'pappy-helpers.brs');
    fs.writeFileSync(helper, fs.readFileSync(path.join(__dirname, 'pappy-checks.brs'), 'utf8')
        .replace('sub Main()', 'sub PappySuite()'));
    for (const suite of ['pappy', 'gigi', 'pops', 'narration', 'upstairs']) {
        const files = [functions];
        if (suite !== 'pappy' && suite !== 'upstairs') files.push(helper);
        if (suite === 'upstairs') files.push(path.join(__dirname, 'upstairs-preview-sprites.brs'));
        files.push(path.join(__dirname, `${suite}-checks.brs`));
        let output = '', errors = '';
        const stdout = new PassThrough(), stderr = new PassThrough();
        stdout.on('data', data => { output += data; });
        stderr.on('data', data => { errors += data; });
        await brs.execute(files, { root, stdout, stderr });
        if (errors || output.includes('FAIL:') || !output.includes('PASS:')) {
            throw new Error(`${suite}: ${errors || output}`);
        }
        console.log(output.split('\n').filter(line => line.startsWith('PASS:')).join('\n'));
        if (suite === 'upstairs' && process.argv[2]) {
            fs.writeFileSync(path.resolve(process.argv[2]), output);
        }
    }
}
main().catch(error => { console.error(error); process.exitCode = 1; })
    .finally(() => fs.rmSync(scratch, { recursive: true, force: true }));

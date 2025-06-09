import { globby } from "globby"; // ← default ではなく名前付き
import prh from "prh";
import assert from "assert";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const ymlList = await globby(["**/*.yml", "!node_modules/**"], {
  cwd: __dirname,
  onlyFiles: true,
});

for (const yml of ymlList) {
  try {
    const engine = prh.fromYAMLFilePath(yml);
    const changeSet = engine.makeChangeSet("./README.ja.md");
  } catch (e) {
    console.log(`processing... ${yml}\n`);
    throw e;
  }
}

console.log("😸 done");

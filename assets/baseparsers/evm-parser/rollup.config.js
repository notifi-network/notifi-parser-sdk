import typescript from "@rollup/plugin-typescript";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import terser from "@rollup/plugin-terser";

export default {
  input: "src/parser.ts",
  plugins: [nodeResolve({}), typescript({}), commonjs()],
  output: [
    {
      format: "esm",
      file: "./dist/parser.js",
    },
    {
      file: "./dist/parser.min.js",
      format: "esm",
      plugins: [terser()],
    },
  ],
};

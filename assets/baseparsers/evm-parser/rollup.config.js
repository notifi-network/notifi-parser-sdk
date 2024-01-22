import typescript from "@rollup/plugin-typescript";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import commonjs from "rollup-plugin-commonjs";
import terser from "@rollup/plugin-terser";

export default {
  input: "src/parser.ts",
  plugins: [nodeResolve({}), typescript({}), commonjs()],
  output: [
    {
      format: "esm",
      file: "./dist/index.js",
    },
    {
      file: "./dist/index.min.js",
      format: "esm",
      plugins: [terser()],
    },
  ],
};

import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))

function readCss(filename: string) {
  return fs.readFileSync(path.join(__dirname, filename), 'utf-8')
}

/**
 * 基础样式 CSS
 */
export const baseCSSContent = readCss('base.css')

/**
 * CSS 主题映射表
 */
export const themeMap = {
  default: readCss('default.css'),
  grace: readCss('grace.css'),
  simple: readCss('simple.css'),
} as const

export type ThemeName = keyof typeof themeMap

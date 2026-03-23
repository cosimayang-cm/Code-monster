import { spawnSync } from 'node:child_process'

const branch = process.env.CF_PAGES_BRANCH ?? ''
const npmCommand = process.platform === 'win32' ? 'npm.cmd' : 'npm'
const script = branch === 'staging' ? 'build:production' : 'build:staging'

console.log(`[build-pages] CF_PAGES_BRANCH=${branch || '(unset)'}`)
console.log(`[build-pages] Running ${script}`)

const result = spawnSync(npmCommand, ['run', script], {
  stdio: 'inherit',
  shell: false,
})

if (typeof result.status === 'number') {
  process.exit(result.status)
}

process.exit(1)

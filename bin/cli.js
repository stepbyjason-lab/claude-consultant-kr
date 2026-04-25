#!/usr/bin/env node
/**
 * consultant-kr-cli — claude-consultant-kr 프로젝트의 npm CLI 진입점
 * npx consultant-kr-cli <command> [options]
 *
 * 지원 명령:
 *   install --local        프로젝트 로컬 설치
 *   install --global       전역 설치
 *   install --check        설치 상태 확인
 *   install --uninstall    제거
 *   industry [options]     산업 특화 에이전트 설치 (install-industry.sh 위임)
 *   humanize [options]     Humanize KR 동적 설치 (install-humanize.sh 위임)
 *
 * 편의:
 *   --local / --global / --check / --uninstall 를 install 없이 바로 써도 동작
 */

const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const PKG_ROOT = path.resolve(__dirname, '..');
const argv = process.argv.slice(2);

function printHelp() {
  console.log(`claude-consultant-kr — 한국 시장 특화 Claude Code 컨설턴트

사용법:
  npx consultant-kr-cli install --local      # 프로젝트 로컬 설치
  npx consultant-kr-cli install --global     # 전역 설치 (~/.claude)
  npx consultant-kr-cli install --check      # 설치 상태 확인
  npx consultant-kr-cli install --uninstall  # 제거
  npx consultant-kr-cli industry --local     # 산업 특화 에이전트 선택 설치
  npx consultant-kr-cli humanize --local     # Humanize KR (외부) 동적 설치

단축 형태 (install 생략 가능):
  npx consultant-kr-cli --local
  npx consultant-kr-cli --global

더 자세한 문서: https://github.com/gaebalai/claude-consultant-kr
`);
}

if (argv.length === 0 || argv[0] === '-h' || argv[0] === '--help') {
  printHelp();
  process.exit(0);
}

if (process.platform === 'win32') {
  console.error('[consultant-kr-cli] Windows 네이티브 셸에서는 동작하지 않습니다.');
  console.error('WSL 또는 Git Bash 에서 실행해주세요.');
  console.error('또는 저장소를 클론한 뒤 bash scripts/install.sh 를 직접 실행하세요.');
  process.exit(1);
}

let subcommand;
let scriptArgs;

if (argv[0] === 'install') {
  subcommand = 'install';
  scriptArgs = argv.slice(1);
} else if (argv[0] === 'industry') {
  subcommand = 'industry';
  scriptArgs = argv.slice(1);
} else if (argv[0] === 'humanize') {
  subcommand = 'humanize';
  scriptArgs = argv.slice(1);
} else if (['--local', '--global', '--check', '--uninstall'].includes(argv[0])) {
  subcommand = 'install';
  scriptArgs = argv;
} else {
  console.error(`알 수 없는 명령: ${argv[0]}`);
  console.error('');
  printHelp();
  process.exit(1);
}

const SCRIPT_MAP = {
  install: 'install.sh',
  industry: 'install-industry.sh',
  humanize: 'install-humanize.sh',
};
const scriptFile = SCRIPT_MAP[subcommand];
const scriptPath = path.join(PKG_ROOT, 'scripts', scriptFile);

if (!fs.existsSync(scriptPath)) {
  console.error(`[consultant-kr-cli] 스크립트를 찾을 수 없습니다: ${scriptPath}`);
  console.error('패키지가 손상되었을 수 있습니다. npm 캐시를 지우고 다시 시도해주세요.');
  console.error('  npm cache clean --force');
  process.exit(1);
}

const child = spawn('bash', [scriptPath, ...scriptArgs], {
  stdio: 'inherit',
  cwd: process.cwd(),
  env: process.env,
});

child.on('error', (err) => {
  if (err.code === 'ENOENT') {
    console.error('[consultant-kr-cli] bash 를 찾을 수 없습니다. bash 설치 후 다시 시도해주세요.');
  } else {
    console.error(`[consultant-kr-cli] 실행 오류: ${err.message}`);
  }
  process.exit(1);
});

child.on('exit', (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
  } else {
    process.exit(code ?? 0);
  }
});

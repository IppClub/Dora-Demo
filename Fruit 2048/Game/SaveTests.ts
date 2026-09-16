/**
 * 存档模块的自动化测试：验证最高分往返读写与失败路径的安全性。
 * 报告首行为 passed / failed；运行时会创建并清理一个探针文件。
 */

import { Content } from 'Dora';
import { BestScoreStore, joinPath, parseScore } from 'Game/Save';

/** 探针文件名（测试结束后会删除）。 */
const PROBE_FILE = 'fruit2048_save_test.txt';

export function runTests(): string {
	const failures: string[] = [];
	let checks = 0;

	const check = (condition: boolean, message: string): void => {
		checks += 1;
		if (!condition && failures.length < 12) {
			failures.push(message);
		}
	};

	check(parseScore('2048') === 2048, 'S8 parseScore 应解析纯数字');
	check(parseScore('') === 0, 'S8 parseScore 空串应返回 0');
	check(parseScore('oops') === 0, 'S8 parseScore 非数字应返回 0');
	check(parseScore('12345xyz') === 12345, 'S8 parseScore 应在前缀数字后停止');

	const probePath = joinPath(Content.writablePath, PROBE_FILE);
	if (Content.exist(probePath)) {
		Content.remove(probePath);
	}

	const store = new BestScoreStore(PROBE_FILE);
	check(store.best === 0, 'S8 无存档时最高分应为 0');
	check(store.submit(1234), 'S8 首次提交应刷新最高分');
	check(store.persisted, 'S8 首次提交应写盘成功');

	const reloaded = new BestScoreStore(PROBE_FILE);
	check(reloaded.best === 1234, 'S8 重新读取应得到 1234');

	const lowered = new BestScoreStore(PROBE_FILE);
	check(!lowered.submit(1000), 'S8 更低分数不应刷新最高分');
	check(lowered.best === 1234, 'S8 更低分数不应覆盖磁盘值');

	const pathWithSlash = joinPath('a/b/', 'c.txt');
	const pathWithoutSlash = joinPath('a/b', 'c.txt');
	check(pathWithSlash === 'a/b/c.txt', 'S8 joinPath 应处理带分隔符的目录');
	check(pathWithoutSlash === 'a/b/c.txt', 'S8 joinPath 应自动补分隔符');

	if (Content.exist(probePath)) {
		Content.remove(probePath);
	}
	const cleaned = new BestScoreStore(PROBE_FILE);
	check(cleaned.best === 0, 'S8 删除存档后应回到 0');

	const lines: string[] = [];
	lines.push(failures.length === 0 ? 'passed' : 'failed');
	lines.push('checks=' + checks + ' failures=' + failures.length);
	for (let i = 0; i < failures.length; i++) {
		lines.push('FAIL ' + failures[i]);
	}
	return lines.join('\n');
}

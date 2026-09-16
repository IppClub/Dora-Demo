/**
 * 最高分持久化：写入 Content.writablePath 下的小文件；读写失败时退化为内存保存。
 */

import { Content } from 'Dora';

/** 默认存档文件名。 */
const BEST_FILE = 'fruit2048_best.txt';

/** 拼接目录与文件名，兼容不同风格的路径分隔符。 */
export function joinPath(dir: string, name: string): string {
	if (dir.length === 0) {
		return name;
	}
	const last = dir.charAt(dir.length - 1);
	if (last === '/' || last === '\\') {
		return dir + name;
	}
	return dir + '/' + name;
}

/** 解析存档文本为分数，遇到非数字或过长内容时安全退出。 */
export function parseScore(text: string): number {
	let value = 0;
	let digits = 0;
	for (let i = 0; i < text.length; i++) {
		const code = text.charCodeAt(i);
		if (code >= 48 && code <= 57) {
			value = value * 10 + (code - 48);
			digits += 1;
			if (digits > 9) {
				break;
			}
		} else if (digits > 0) {
			break;
		}
	}
	return value;
}

/** 最高分存储：优先落盘，失败时仅保留在内存。 */
export class BestScoreStore {
	path: string;
	best: number;
	/** 上次写盘是否成功。 */
	persisted: boolean;

	constructor(fileName?: string) {
		const name = fileName ? fileName : BEST_FILE;
		this.path = joinPath(Content.writablePath, name);
		this.best = 0;
		this.persisted = true;
		this.load();
	}

	/** 从磁盘读取最高分；文件缺失或内容非法时保持当前内存值。 */
	load(): number {
		if (!Content.exist(this.path)) {
			return this.best;
		}
		const text = Content.load(this.path);
		if (text === undefined) {
			return this.best;
		}
		const value = parseScore(text);
		if (value > this.best) {
			this.best = value;
		}
		return this.best;
	}

	/** 提交新分数，返回是否刷新了最高分。 */
	submit(score: number): boolean {
		if (score <= this.best) {
			return false;
		}
		this.best = score;
		this.save();
		return true;
	}

	/** 写盘；失败时只保留内存值并记录状态。 */
	save(): boolean {
		const ok = Content.save(this.path, '' + this.best);
		if (!ok) {
			this.persisted = false;
		}
		return ok;
	}
}

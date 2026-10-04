/**
 * model-prompts: per-provider instructions instead of a global AGENTS.md.
 *
 * Before each run, if <dir>/<provider>.md exists for the active model's provider
 * (e.g. halo.md for the local Qwen), its text becomes the `model_guidance`
 * system-prompt section; other providers get Pi's default prompt.
 *
 * Config (env): PI_MODEL_PROMPTS_DIR (default ~/.pi/agent/model-prompts).
 * Point it at another directory to A/B a variant; an empty directory disables it.
 */

import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const dir = process.env.PI_MODEL_PROMPTS_DIR || join(homedir(), ".pi", "agent", "model-prompts");

export default function modelPrompts(pi: ExtensionAPI) {
	pi.on("before_agent_start", (event, ctx) => {
		const provider = ctx.model?.provider;
		const file = provider ? join(dir, `${provider}.md`) : "";
		const sections = event.systemPromptOptions.sections;
		if (file && existsSync(file)) {
			sections.model_guidance = readFileSync(file, "utf8").trim();
		} else {
			delete sections.model_guidance;
		}
	});
}

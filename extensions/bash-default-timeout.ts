/**
 * bash-default-timeout: give model-issued bash calls a default timeout.
 *
 * Pi's bash tool has no default timeout, so a command that runs far longer than
 * expected (e.g. an O(n^2) script on a big input) blocks the agent until someone
 * notices. With a default, the model gets "Command timed out after N seconds"
 * and can retry on smaller input or pass a larger `timeout` explicitly.
 *
 * Config (env): PI_BASH_DEFAULT_TIMEOUT seconds (default 120; 0 disables).
 * Calls that already set `timeout` are left alone; user `!` commands are not tool calls.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const seconds = Number(process.env.PI_BASH_DEFAULT_TIMEOUT ?? 120);

export default function bashDefaultTimeout(pi: ExtensionAPI) {
	if (!(seconds > 0)) return;
	pi.on("tool_call", (event) => {
		if (event.toolName === "bash" && event.input.timeout === undefined) {
			event.input.timeout = seconds;
		}
	});
}

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("confirm", {
    description: "Send a prompt with confirmation request",
    handler: async (args, ctx) => {
      if (!args || !args.trim()) {
        ctx.ui.notify("Usage: /confirm <your prompt>", "warning");
        return;
      }

      // Append the confirmation suffix to the prompt
      const modifiedPrompt = `${args}\n\nBefore you make any changes, please confirm that you understand the task?`;

      // Send the modified prompt to the agent
      pi.sendUserMessage(modifiedPrompt);
    },
  });
}

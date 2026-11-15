After we have handled an email thread (replied, logged it in the vault, or
decided nothing is needed), move it out of the inbox.

1. Suggest a folder: the existing Gmail label for the counterparty or project
   (list them with `gws gmail users labels list --params '{"userId":"me"}'`).
   Suggest a new label only when no existing one fits.
2. Ask for permission and name the thread, the label and "archive from the
   inbox". Several threads can be approved in one question.
3. After approval, run `gws gmail users threads modify` with `addLabelIds` for
   the label and `removeLabelIds: ["INBOX"]`. The claude.ai Gmail connector
   cannot label or archive.
4. Report what was moved. A thread that is still waiting on a reply can be
   archived too, because a new reply comes back to the inbox.

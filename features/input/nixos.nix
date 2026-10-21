# PURPOSE: Enable libinput (input device plumbing, not laptop-specific policy).
# Personal scroll/focus preferences live under users/<name>/preferences.
{ ... }: { services.libinput.enable = true; }

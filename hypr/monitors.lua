------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@180",
    position = "0x0",
    scale    = "auto",
})

hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@144",
    position = "1920x0",
    scale    = "auto",
})

hl.workspace_rule({ workspace = "name:Main", monitor = "DP-3", default = true })
hl.workspace_rule({ workspace = "name:Secondary", monitor = "DP-2", default = true })
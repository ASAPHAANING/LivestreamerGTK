public void mainLoop (string s, string q)
            {
                string quality = q;
                switch (q)
                {
                    case "Source":  quality = "best";   break;
                    case "High":    quality = "high";   break; 
                    case "Medium":  quality = "medium"; break;
                    case "Low":     quality = "low";    break;
                    case "Mobile":  quality = "mobile"; break;
                    case "Audio":   quality = "audio";  break;
                }
                string url = s;
                MainLoop loop = new MainLoop ();
                try {
                string[] spawn_args = {"livestreamer", "-p=mpv", "--ringbuffer-size=32M", "--player-passthrough", "hls", "--hls-segment-threads", "3", url, quality};
                string[] spawn_env = Environ.get ();
                Pid child_pid;
                
                Process.spawn_async ("/",
                spawn_args,
                spawn_env,
                SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                null,
                out child_pid);
                
                ChildWatch.add (child_pid, (pid, status) => {
                // Triggered when the child indicated by child_pid exits
                Process.close_pid (pid);
                loop.quit ();
                });
                
                loop.run ();

                } catch (SpawnError e) {
                stdout.printf ("Error: %s\n", e.message);
                }
            }
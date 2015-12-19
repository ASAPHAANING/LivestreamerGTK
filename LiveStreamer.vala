    using Gtk;

    namespace LiveStreamer
    {
        class LiveStreamerGTK : Gtk.Window
        {
            public LiveStreamerGTK ()
            {
                var grid = new Grid();
                var button = new Button.with_label("Go");
                var url = new EntryBuffer(null);
                var text = new Entry.with_buffer (url);
                ListStore list_store = new Gtk.ListStore (2, typeof (string), typeof (int));
                TreeIter iter;
                list_store.append (out iter);
                list_store.set (iter, 0, "Burgenland", 1, 13);
                list_store.append (out iter);
                list_store.set (iter, 0, "Carinthia", 1, 17);
                ComboBox box = new Gtk.ComboBox.with_model (list_store);
                this.add (box);
                
                Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
                box.pack_start (renderer, true);
                box.add_attribute (renderer, "text", 0);
                box.active = 0;
                
                renderer = new Gtk.CellRendererText ();
                box.pack_start (renderer, true);
                box.add_attribute (renderer, "text", 1);
                box.active = 0;
                
                box.changed.connect (() => {
                Value val1;
                Value val2;
                
                box.get_active_iter (out iter);
                list_store.get_value (iter, 0, out val1);
                list_store.get_value (iter, 1, out val2);
                });
                button.clicked.connect (launchLiveStreamer);
                text.activate.connect (launchLiveStreamerText);
                grid.attach(text,0,0,200,10);
                grid.attach_next_to(button,text, Gtk.PositionType.RIGHT, 10,10);
                add (grid);
                title = "LiveStream GTK Launcher";
                border_width = 20;
                window_position = WindowPosition.CENTER;
                set_default_size (250, 150);

            }

            public void launchLiveStreamerText (Entry entry)
            {
            unowned string str = entry.get_text ();
            if(str != "") { stdout.printf ("%s\n", str); }
            mainLoop(str);
            }

            public void launchLiveStreamer (Gtk.Button button)
            {
                //string output = url.get_text();
                //stdout.printf("%s\n", output);            
            }

            public void mainLoop (string s)
            {
                string url = s;
                MainLoop loop = new MainLoop ();
                try {
                string[] spawn_args = {"livestreamer", "-p=mpv", "--ringbuffer-size=32M", "--player-passthrough", "hls", "--hls-segment-threads", "3", url, "best"};
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


            public static int main (string[] args) {
            Gtk.init (ref args);

            var app = new LiveStreamerGTK();

            app.destroy.connect (Gtk.main_quit);
            app.show_all ();
            Gtk.main ();
            return 0;
        }
    }
}
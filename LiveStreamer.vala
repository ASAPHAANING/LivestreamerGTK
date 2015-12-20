    using Gtk;

    namespace LiveStreamer
    {
        class LiveStreamerGTK : Gtk.Window
        {

            string quality = "Source";
            File database = File.new_for_path ("database.txt");

            public LiveStreamerGTK ()
            {
                var grid = new Grid();
                var button = new Button.with_label("Go");
                var url = new EntryBuffer(null);
                var text = new Entry.with_buffer (url);

                string recent = readDatabase(database);
                
                text.set_text(recent);
                ListStore list_store = new Gtk.ListStore (1, typeof (string));
                TreeIter iter;
                list_store.append (out iter);
                list_store.set (iter, 0, "Source", -1);
                list_store.append (out iter);
                list_store.set (iter, 0, "High", -1);
                list_store.append (out iter);
                list_store.set (iter, 0, "Medium", -1);
                list_store.append (out iter);
                list_store.set (iter, 0, "Low", -1);
                list_store.append (out iter);
                list_store.set (iter, 0, "Mobile", -1);
                list_store.append (out iter);
                list_store.set (iter, 0, "Audio", -1);
                ComboBox box = new Gtk.ComboBox.with_model (list_store);
                
                Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
                box.pack_start (renderer, true);
                box.add_attribute (renderer, "text", 0);
                box.active = 0;
                
                box.changed.connect (() => {
                    Value val1;
                    
                    box.get_active_iter (out iter);
                    list_store.get_value (iter, 0, out val1);
                    quality = (string) val1;
                    });

                button.clicked.connect (launchLiveStreamer);
                text.activate.connect (launchLiveStreamerText);
                grid.attach(text,0,0,200,10);
                grid.attach_next_to(button,text, Gtk.PositionType.RIGHT, 10,10);
                grid.attach_next_to(box,button,PositionType.RIGHT, 10,10);
                add (grid);
                title = "LiveStream GTK Launcher";
                border_width = 20;
                window_position = WindowPosition.CENTER;
                set_default_size (250, 150);

            }

            public void launchLiveStreamerText (Entry entry)
            {
                unowned string str = entry.get_text ();
                try {
                if(str != "") { stdout.printf ("%s\n", str); }
                if(database.query_exists ()) { database.delete(); }
                var dos = new DataOutputStream (database.create (FileCreateFlags.REPLACE_DESTINATION));
                dos.put_string(entry.get_text());
                }
                catch (Error e)
                {
                    return;
                }
                mainLoop(str,quality);
            }

            public void launchLiveStreamer (Gtk.Button button)
            {
                //string output = url.get_text();
                //stdout.printf("%s\n", output);            
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
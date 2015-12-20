public string readDatabase (File database)
{

	if (!database.query_exists ()) {
		stderr.printf ("File '%s' doesn't exist.\n", database.get_path ());
	}

	try {
                    // Open file for reading and wrap returned FileInputStream into a
                    // DataInputStream, so we can read line by line
                    var dis = new DataInputStream (database.read ());
                    string line = dis.read_line(null);
                    return line;
                    } catch (Error e) {
                    	error ("%s", e.message);
                    }
}
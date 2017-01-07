using Gee;

HashMap<string, string> macros;


int main (string[] argv) {

    if (argv.length != 2) {
        stderr.printf ("This takes exactly one argument!\n");
        return 1;
    }


    string raw = "";

    var file = File.new_for_path (argv[1]);

    if (!file.query_exists ()) {
        stderr.printf ("File '%s' doesn't exist.\n", file.get_path ());
        return 1;
    }

    try {
        // Open file for reading and wrap returned FileInputStream into a
        // DataInputStream, so we can read line by line
        var dis = new DataInputStream (file.read ());
        string line;
        // Read lines until end of file (null) is reached
        while ((line = dis.read_line (null)) != null) {
            raw += "%s\n".printf (line);
        }
    } catch (Error e) {
        stderr.printf ("File Error");
        return 1;
    }

    macros = new HashMap <string, string> ();
    
    string[] segments = raw.split (">>=\n");
    
    for (int i = 1; i<segments.length; i++) {
        string[] temp = segments[i].split ("\n@\n");
        if (temp.length == 1) {
            stderr.printf ("Invalid Syntax (missing @)\n");
            return 1;
        }
        string macro = temp[0];
        
        temp = segments[i-1].split ("<<");
        if (temp.length == 1) {
            stderr.printf ("Invalid Syntax!\n");
            return 1;
        }
        string name = temp[temp.length - 1];
        
        macros [name] = macro;
    
    }    
    
    if (!macros.has_key ("main")) {
        stderr.printf ("no main macro!\n");
        return 2;
    }
    
    string output = build ("main");
    
    string filename;
    
    string[] temp = argv[1].split(".");
    
    filename = "%s.vala".printf (temp[0]);
    
    
    
    try {
        // an output file in the current working directory
        var file_out = File.new_for_path (filename);

        // delete if file already exists
        if (file_out.query_exists ()) {
            file_out.delete ();
        }
        
        var dos = new DataOutputStream (file_out.create (FileCreateFlags.REPLACE_DESTINATION));
        
        dos.put_string (output);
        
    } catch (Error e) {
        stderr.printf ("%s\n", e.message);
        return 1;
    }

    
    return 0;
}


string? build (string macro) {
    if (!macros.has_key (macro)) {
        stderr.printf ("Macro '%s' used, but never declared\n", macro);
    }
    
    string [] temp = macros [macro].split ("<<");


    if (temp.length == 1) {
        return macros [macro].replace ("\\>", ">").replace("\\<", "<");
    }
    
    string ret = temp[0];
    
    for (int i = 1; i<temp.length; i++) {
        
        string[] t2 = temp[i].split (">>");
        if (t2.length != 2) {
            stderr.printf ("Error occured while building %s!", macro);
            return null;
        }
        string name = t2[0].replace ("\\>", ">").replace("\\<", "<");
        string code = build (name);
        if (code == null) {
            return null;
        }
        ret += code;
        ret += t2[1];
    
    }

    return ret;
}

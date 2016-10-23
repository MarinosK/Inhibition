/*
 * by Marinos Koutsomichalis (me@marinoskoutsomichalis.com)
*/

Include {

	*initClass { 
		//		Class.initClassTree(Strict); 
		Class.initClassTree(PathName); 
	} 
	
	*new{ arg path;
		var p = Strict(String,path);
		if (PathName(p).isAbsolutePath) {
			^this.absolute(p);
		} {
			^this.relative(p);
		}
	}
	
	*absolute{ arg path;
		^path.loadPaths;
	}

	*relative{ arg path;
		var pathToLoad = File.getcwd +/+ path;
		^pathToLoad.loadPaths;
	}
}
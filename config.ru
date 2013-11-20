app = lambda do |env|
	fileType = nil
 	env["QUERY_STRING"].split(",").each do |params|
		(n ,v) = params.split("=")
		if n == "fileType"
			fileType = v
		else
			break
		end	
	end 

	appname = nil
	if m = env["REQUEST_URI"].match(/(.*)(\/sj\/|\/sj_ext\/)(.*)/)
		contextpart1 = m[1]
		appname = m[2]
		apprelpath = m[3]
	end		
    publicDir = "#{env["DOCUMENT_ROOT"]}#{appname}"
    if (fileType.nil? || (fileType!="conf" && fileType!="trace"))
			aslinks = true
	    browsedir = "#{publicDir}#{apprelpath}/"
		else
			aslinks = false
	    browsedir = "#{publicDir}/files/#{fileType}/"
		end
		if !File.exists?(browsedir)
			body = "0"
		else
			actualDir = Dir.getwd
	    Dir.chdir(browsedir)
	    files = Dir.glob("*.*")
	    Dir.chdir(actualDir)
			if aslinks
				body = "<html><head></head><body>" 
				body += "<ul>" 
				files.each do |fn|
					body += "<li><a href='#{contextpart1}#{appname}#{apprelpath}#{fn}'> #{fn} </a></li>"
				end
				body += "</ul>" 
				body += "</body></html>" 
			else
	    body=files.join("\n") + "\n"
			end
	end	
 	[200, { 'Content-Type' => 'text/html' }, body] 
end
run app

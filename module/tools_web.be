import tools_constants as constants
import tools_logger as logger

def read_url(url, retries)

    var client = webclient()
    client.begin(url)
    var status=client.GET()
    if status==200
        return client.get_string()
    else
        logger.logger.error(string.format('Error reading "%s". Code %s', url, status))
        return false
    end

end

def download_url(url, file_path, retries)    

    retries=retries==nil?10:retries

    try
        tasmota.urlfetch(url,file_path)
        return true
    except .. as exception

        logger.logger.error(string.format('Error downloading URL "%s" (Code: %s). Retries remaining: %s.', url, exception, retries))

        retries-=1
        if !retries
            return false
        else
            return download_url(url,file_path,retries)
        end

    end
end

def resolve_redirects(url)

    if !constants.WEB_CLIENT_SUPPORTS_REDIRECTS
        raise 'runtime_error', 'Resolving redirects requires Tasmota >=12.5.0'
    end

	var client = webclient()
	client.set_follow_redirects(false)
	client.collect_headers("Location")
	client.begin(url)
	var response = client.GET()
	if response == 301 || response == 302
	    url=client.get_header("Location")
	elif response == 200
	    url=url
	else
	    client.close()
		raise 'connection_error','status: '+str(response)
	end
	client.close()
	return url

end

var mod = module("tools_web")

mod.read_url=read_url
mod.download_url=download_url
mod.resolve_redirects=resolve_redirects

return mod
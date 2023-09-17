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

class Downloader

	static var rule_id='DownloaderTimer'
	static var delay=2

	var url,path,tries,cb_success,cb_failure,wc

	def init(url,path,cb_success,cb_failure,tries)

		self.url=url

		if path==nil
		  import string
		  path = string.split(url,'/').pop()
		  if size(path) == 0
			path = 'index.html'   # fallback in case you fetch a root file
		  end
		end

		self.path=path
		self.tries=tries?tries:10
		self.cb_success=cb_success?cb_success:/->nil
		self.cb_failure=cb_failure?cb_failure:/->nil

		self.wc=webclient()

		self.download(tries)

	end

	def download(tries)

		import string

		var code=self.try_download()
		var msg

		if code== 200
			self.close()
			msg=string.format('Successfully downloaded "%s" to "%s".', self.url, self.path)
			print(msg)
			return self.cb_success()
		else

			msg=string.format('connection_error for "%s" status: %s. Remaining tries: %s', self.url, code, tries)
			print(msg)

			if tries==0
				self.close()
				msg=string.format('Failed downloading "%s" to "%s".', self.url, self.path, code)
				print(msg)
				return self.cb_failure()
			end

			tries-=1

			tasmota.remove_timer(self.rule_id)
			tasmota.set_timer(self.delay*1000,/->self.download(tries),self.rule_id)

		end

	end

	def try_download()

		self.wc.set_follow_redirects(true)
		self.wc.begin(self.url)
		var code = self.wc.GET()
		if code != 200
			return code
		end
		self.wc.write_file(self.path)
		return code

	end

	def close()

		tasmota.remove_timer(self.rule_id)
		self.wc.close()

	end

	def deinit()

		print('deinit')
		return self.close()

	end



end

var mod = module("tools_web")

mod.read_url=read_url
mod.download_url=download_url
mod.resolve_redirects=resolve_redirects
mod.Downloader=Downloader

return mod
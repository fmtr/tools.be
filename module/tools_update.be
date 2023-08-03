import tools_web
import tools_logger as logger

def update_tapp(name, url,path_module)    

    logger.logger.info(string.format('Starting %s update from URL "%s"...', name, url))

    var is_download_success=tools_web.download_url(url,path_module,nil)
    if is_download_success
        logger.logger.info(string.format('Download %s update succeeded. File written to "%s". Restarting...', name, path_module))
        tasmota.cmd('restart 1')        
        return true
    else
        logger.logger.error(string.format('Download %s update failed.', name))
        return false
    end    

end

def get_latest_release_tag_github(org,repo)    

	import string
	var url=string.format("https://github.com/%s/%s/releases/latest",org,repo)

    logger.logger.info(string.format('Fetching latest GitHub release tag for %s/%s from URL: "%s"', org, repo, url))

	url=tools_web.resolve_redirects(url)
	return string.split(url,'/').pop()

end

def get_latest_version_github(org,repo)   

	import string
	var version=get_latest_release_tag_github(org,repo)
	for v: ['v','V']
		version=string.replace(version,'v','')
	end

    logger.logger.info(string.format('Found latest GitHub version for %s/%s from URL: %s', org, repo, version))

	return version

end

def update_tapp_github_asset(url, org, repo, asset_filename, path_module)

    if string.find(url,'http')==0
        return update_tapp(repo, url, path_module)
    end

    var version=url
    path_module=path_module?path_module:('/'+asset_filename)
    
    if version==nil        
        version=get_latest_version_github(org,repo)        
    end

    if string.find(version,'http')!=0
        url=string.format('https://github.com/%s/%s/releases/download/v%s/%s',org,repo,version,asset_filename)
        logger.logger.info(string.format('Update from GitHub Asset: Updating from specified version (%s) from URL: "%s"',version,url))
    end

    return update_tapp(repo, url, path_module)

end

var mod = module("tools_update")
mod.update_tapp=update_tapp
mod.get_latest_version_github=get_latest_version_github
mod.get_latest_release_tag_github=get_latest_release_tag_github
mod.update_tapp_github_asset=update_tapp_github_asset

return mod
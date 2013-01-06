require 'yaml'
require 'fileutils'

VENDOR_DIRECTORY = "vendor"
DEPENDENCY_MANIFEST = "manifest.yml"
PLUGIN_DIRECTORY = "_plugins"

task :default do  
  puts 'Building ...'
  fetch_dependencies
  jekyll
end

task :rebuild do
  remove_dependencies
  fetch_dependencies
  jekyll
end

def jekyll
  command = "jekyll"
  
  if File.file?("is_production")
    command = command + " --no-future"
  end
  
  system(command)
end

def remove_dependencies  
  config = YAML.load_file("manifest.yml")
  
  config.each do |dependency_group,dependency_group_values|    
    dependency_group_values.each do |dependency|
      dependency.each do |name,url|
        dependency_directory =  dependency_group + "/" + name
        
        puts "Removing " + dependency_directory
        if File.directory?(dependency_directory)
          FileUtils.rm_rf dependency_directory     
        end
      end
    end
  end  
end


def fetch_dependencies
  config = YAML.load_file("manifest.yml")
  
  config.each do |dependency_group,dependency_group_values|
    if !File.directory?(dependency_group)
      Dir::mkdir(dependency_group);
    end
    
    dependency_group_values.each do |name,url|
      dependency_directory = dependency_group + "/" + name
      puts "Fetching " + dependency_directory + " from " + url
      
      if !File.directory?(dependency_directory)
        Dir::mkdir(dependency_directory)
        
        if vendor_is_repository(url)
          system("cd " + dependency_directory + " && git clone " + url)
        else
          system("cd " + dependency_directory + " && wget " + url)
          
          if vendor_is_zip_archive(url)
            system("cd " + dependency_directory + " && unzip -q " + get_filename_from_url(url))
            system("cd " + dependency_directory + " && rm -Rf " + get_filename_from_url(url))
          end
          
          if vendor_is_bz2_archive(url)
            system("cd " + dependency_directory + " && tar -jxvf " + get_filename_from_url(url))
            system("cd " + dependency_directory + " && chmod -R 0755 *")
            system("cd " + dependency_directory + " && rm -Rf " + get_filename_from_url(url))            
          end

          if vendor_is_github_master(url)
            system("cd " + dependency_directory + " && unzip -q " + get_filename_from_url(url))
            system("cd " + dependency_directory + " && rm -Rf " + get_filename_from_url(url))
            system("cd " + dependency_directory + " && mv *-* latest ")
          end
        end
      end
     
    end
  end
end

def get_filename_from_url(url)
  url.split("/").last
end

def get_extension_from_filename_from_url(url)
  url.split(".").last
end

def vendor_is_github_master(url)
  return get_filename_from_url(url) == "master"
end

def vendor_is_repository(url)
  get_extension_from_filename_from_url(url) == "git"
end

def vendor_is_zip_archive(url)
  get_extension_from_filename_from_url(url) == "zip"
end

def vendor_is_bz2_archive(url)
  get_extension_from_filename_from_url(url) == "bz2"
end

def vendor_is_archive(url)
  if vendor_is_zip_archive(url)
    return true
  end
  
  if vendor_is_bz2_archive(url)
    return true
  end  
  
  return vendor_is_github_master(url)
end
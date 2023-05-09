#!/bin/bash

# TODO: maybe add a -u or --update option to update the local list of languages/frameworks/libraries
# TODO: maybe use variables for the colors instead of hardcoding them eheheh...
# TODO: maybe add a -s or --silent option to hide the curl output and a verbose option to show more information
# TODO: maybe add a -f or --force option to force the overwriting of the template file (to overcome permission issues maybe idk eheheh...)
# FIXME: stop saying eheheh... people might think I'm a child or something eheheh...
# TODO: maybe add a -d or --debug option to show more information about the script execution
# TODO: I think there is some refactoring to do especially in the template part and the sorting/processing of the inputs
# TODO: The script works fine but still need more error handling and testing
# TODO: Maybe let the user choose the separator for the languages/frameworks/libraries (e.g. space, comma, semicolon, etc.)
# TODO: Using environment variables to set the default values for the options would be nice
# TODO: I would love to ping an API everytime the script is used to count the number of times it is used and the number of languages/frameworks/libraries used but I don't know if it's legal or not eheheh...
# TODO: Add a test suite to test the script, maybe make it available as a GitHub action, or even as a flag in the script itself eheheh...
# FIXME: column: line too long, maybe use a variable for the column width
# TODO: Add support to check if the script is up to date and if not, prompt the user to update it

# Define the script values
script_name="gitignore"
script_version="1.0"
script_description="A simple script to generate a .gitignore file for your project using the gitignore.io API."
script_author="adia-dev (on GitHub)"
script_website="https://github.com/adia-dev"
script_license="MIT License"
script_install_path="/usr/local/bin"

function gitignore() {
  # Feel free to edit the following values :)
  gitignore_api_url="https://www.toptal.com/developers/gitignore/api"
  gitignore_path="$HOME/.gitignore.io"
  # gitignore_path="./.gitignore.io" # TODO: change this to the line above when the script is ready to be used
  gitignore_template_path="$gitignore_path/templates"
  gitignore_refresh_time=259200 # 3 days

  # Define default values
  output_file=".gitignore"
  append=false  # if true, append to the existing gitignore file instead of overwriting it
  languages=""  # comma-separated list of languages/frameworks/libraries
  verbose=false # if true, show more information about the script execution

  # Define default values for the template options
  use_template=false
  overrite_template=false
  template_name="" # if no template name is specified, the default template will be used

  # Welcome message if there is no argument
  if [ $# -eq 0 ]; then
    echo "Welcome to the $script_name script!"
    echo "$script_description"
    echo "Author: $script_author"
    echo "Website: $script_website"
    echo "License: $script_license"
    echo ""
    echo "To generate a gitignore file for specific languages, frameworks or libraries, provide their names as comma-separated arguments."
    echo ""
    echo "Example: gitignore -o my_gitignore_file node,react,angular,django"
    echo ""
    echo "To show the list of available languages/frameworks/libraries, use the -l or --list option."
    echo ""
    echo "Example: gitignore -l"
    echo ""
    echo "To show the command manual, use the -h or --help option."
    echo ""
    echo "Example: gitignore -h"
    echo ""
    echo "To show the version information, use the -v or --version option."
    echo ""
    echo "Example: gitignore -v"
    echo ""
    echo "To install the script, use the -i or --install option."
    echo ""
    echo "Example: gitignore -i"
    echo ""
    echo "To uninstall the script, use the -u or --uninstall option."
    echo ""
    echo "Example: gitignore -u"
    echo ""
    echo "To clear the local list of languages/frameworks/libraries, use the -c or --clear-cache option."
    echo ""
    echo "Example: gitignore -c"
    echo ""
    echo "To use a custom template, use the -t or --template option."
    echo ""
    echo "Example: gitignore -t my_template node,react,angular,django"
    echo ""
    echo "To overwrite an existing template, use the -o or --overwrite-template option."
    echo ""
    echo "Example: gitignore -o -t my_template node,react,angular,django"
    echo ""
    echo "To show more information about what the script is doing, use the --verbose option."
    echo ""
    echo "Example: gitignore --verbose"
    echo ""
    return 0
  fi
  # check if the directory for the local list of languages/frameworks/libraries exists if not create it
  if [ ! -d "$gitignore_path" ]; then
    echo "Warning: The directory for the local list of languages/frameworks/libraries does not exist."
    echo "We will create it now, you can delete it later if you want with the -c or --clear-cache option. :)"

    echo ""
    echo "RUNNING: mkdir -p \"$gitignore_path\""
    echo ""
    mkdir -p "$gitignore_path"
    if [ $? -ne 0 ]; then
      echo "Error: Could not create the directory for the local list of languages/frameworks/libraries."
      echo "This is probably due to a permission issue."
      return 1
    fi

    echo ""
    echo "Success: The directory for the local list of languages/frameworks/libraries has been created."
  fi

  # Parse arguments
  while [[ "$#" -gt 0 ]]; do
    case $1 in
    -o | --output)
      output_file="$2"
      shift
      ;;
    -a | --append) append=true ;;
    -h | --help)
      echo "gitignore Command Manual"
      echo ""
      echo "Usage: gitignore [options] [languages/frameworks/libraries,...]"
      echo ""
      echo "If no argument is provided, a default gitignore file will be generated."
      echo ""
      echo "To generate a gitignore file for specific languages, frameworks or libraries, provide their names as comma-separated arguments."
      echo ""
      echo "Example: gitignore -o my_gitignore_file node,react,angular,django"
      echo ""
      echo "Options:"
      echo ""
      echo "  -o, --output FILENAME   Specify the output filename for the generated gitignore file. The default is \".gitignore\"."
      echo "  "
      echo "  -a, --append            Append to the existing gitignore file instead of overwriting it."
      echo "  "
      echo "  -h, --help              Show this help message and exit."
      echo "  "
      echo "  -l, --list              Show the list of available languages/frameworks/libraries and exit."
      echo "  "
      echo "  -t, --template NAME     Use a custom template from the ~/.gitignore.io/templates directory if it exists, if not it'll create it with the specified languages/frameworks/libraries."
      echo "                          If no template name is specified, the default template will be used."
      echo "                          To overrite an existing template, use the -o or --overwrite-template option."
      echo "  "
      echo "  -c, --clear-cache       Clear the local list of languages/frameworks/libraries."
      echo "  "
      echo "  -i, --install           Install the script in the /usr/local/bin directory."
      echo "  "
      echo "  -v, --version           Show the version information and exit."
      echo "  "
      echo "  -u, --uninstall         Uninstall the script from the /usr/local/bin directory."
      echo ""
      echo "  --verbose               Show more information about what the script is doing."
      echo ""
      echo "Example of available languages/frameworks/libraries:"
      echo ""
      echo "- node"
      echo "- react"
      echo "- rust"
      echo "- c++"
      echo "- rails"
      echo "- laravel"
      echo "- wordpress"
      echo "- drupal"
      echo "- visualstudiocode"
      echo "- macos"
      echo "- ..."
      echo ""
      echo "To see this manual again, use the -h or --help option."
      echo "To see the latest list of available languages/frameworks/libraries, use the -l or --list option."
      echo "To clear the local list of languages/frameworks/libraries, use the -c or --clear-cache option."
      echo "To see the version information, use the -v or --version option."
      echo ""
      echo "Visit my GitHub repository for more information: https://github.com/adia-dev/gitignore"
      echo "Thanks to gitignore.io for providing the list of languages/frameworks/libraries."
      echo "Visit them at: https://github.com/toptal/gitignore.io"
      echo ""
      return 1
      ;;
    -v | --version)
      echo "gitignore version 1.0"
      return 1
      ;;
    -l | --list)
      # check the local list of languages/frameworks/libraries or fetch the latest list from the gitignore.io website
      if [ ! -f "$gitignore_path/available_gitignores" ] || [ $(($(date +%s) - $(date -r "$gitignore_path/available_gitignores" +%s))) -gt "$gitignore_refresh_time" ]; then
        echo "No local list of languages/frameworks/libraries found or the list is older than 3 days. Fetching the latest list..."
        # check if the directory for the local list of languages/frameworks/libraries exists if not create it
        if [ ! -d "$gitignore_path" ]; then
          echo "The directory for the local list of languages/frameworks/libraries does not exist."
          echo "We will create it now, you can delete it later if you want with the -c or --clear-cache option. :)"
          mkdir -p "$gitignore_path"
          if [ $? -ne 0 ]; then
            echo "Error: Could not create the directory for the local list of languages/frameworks/libraries."
            echo "This is probably due to a permission issue."
            echo "Try running the script with as root or with sudo."
            echo "If you don't want to use the local list of languages/frameworks/libraries, you can use the -c or --clear-cache option."
            return 1
          fi
        fi
        curl -sSL $gitignore_api_url/list >"$gitignore_path/available_gitignores"
        if [ $? -ne 0 ]; then
          echo "An error occurred while fetching the list of languages/frameworks/libraries."
          echo "It might be related to your internet connection or the gitignore.io website might be down."
          echo "Or you could try running the script with as root or with sudo."
          echo "Clear the local list of languages/frameworks/libraries with the -c or --clear-cache option first if you want to try again."
          echo "Please try again later."
          return 1
        fi
      else
        echo "Using the local list of languages/frameworks/libraries..." | sed -e 's/^/[90m/' -e 's/$/[0m/'
      fi
      # print the list of languages/frameworks/libraries and exit
      echo "Available languages/frameworks/libraries:"
      # pretty print the list of languages/frameworks/libraries, separated by commas, print as a list of 4 columns sorted alphabetically
      # cat "$gitignore_path" | sed -e 's/,/, /g' | column -t -s, -c 80 | sort
      # add error handling
      if [ $? -eq 0 ]; then
        cat "$gitignore_path/available_gitignores" | sed -e 's/,/, /g' | column -t -s, -c 80 | sort
      else
        echo "An error occurred while fetching the list of languages/frameworks/libraries."
        echo "Please try again later."
      fi
      return 1
      ;;
    -t | --template)
      use_template=true
      template_name="$2"
      languages="$3"
      if [ "$4" = "-o" ] || [ "$4" = "--overwrite-template" ]; then
        overrite_template=true
      fi
      shift
      ;;
    -c | --clear-cache)
      rm -rf "$gitignore_path/*"
      echo "The local list of languages/frameworks/libraries has been deleted."
      return 1
      ;;
    -i | --install)
      # check if the script is already installed
      if [ -f "$script_install_path/$script_name" ]; then
        echo "The script is already installed."
        return 1
      fi
      # check if the user is root
      if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root."
        return 1
      fi
      # check if the script is in the current directory
      if [ ! -f "$script_name" ]; then
        echo "The script is not in the current directory."
        return 1
      fi

      if [ ! -d "$script_install_path" ]; then
        mkdir -p "$script_install_path"
      fi

      # copy the script to the /usr/local/bin directory
      cp "$script_name" "$script_install_path/$script_name"
      # check if the script was copied successfully
      if [ $? -eq 0 ]; then
        echo "The script has been installed successfully at $script_install_path/$script_name"
        # make the script executable and hide it from the Finder, new cool trick I learned eheh
        chmod +x "$script_install_path/$script_name"
        chflags hidden "$script_install_path/$script_name"
        echo "You can now use the gitignore command from anywhere."
      else
        echo "An error occurred while installing the script."
        echo "Please try again later."
      fi

      #TODO: add support for other shells if needed
      # check if the user is using bash
      if [ -f "$HOME/.bashrc" ]; then
        echo "export PATH=\"\$PATH:$script_install_path\"" >>"$HOME/.bashrc"
      fi
      # check if the user is using zsh
      if [ -f "$HOME/.zshrc" ]; then
        echo "export PATH=\"\$PATH:$script_install_path\"" >>"$HOME/.zshrc"
      fi
      # check if the user is using fish
      if [ -f "$HOME/.config/fish/config.fish" ]; then
        echo "set PATH \$PATH $script_install_path" >>"$HOME/.config/fish/config.fish"
      fi
      # check if the user is using csh
      if [ -f "$HOME/.cshrc" ]; then
        echo "set path = ( \$path $script_install_path )" >>"$HOME/.cshrc"
      fi
      return 1
      ;;
    -u | --uninstall)
      # check if the script is installed
      if [ ! -f "$script_install_path/$script_name" ]; then
        echo "The script is not installed."
        return 1
      fi
      # check if the user is root
      if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root."
        return 1
      fi
      # remove the script from the /usr/local/bin directory
      rm -f "$script_install_path/$script_name"
      # check if the script was removed successfully
      if [ $? -eq 0 ]; then
        echo "The script has been uninstalled successfully."
      else
        echo "An error occurred while uninstalling the script."
        echo "Please try again later."
      fi

      return 1
      ;;
    --reinstall)
      # try running the uninstall script first and then the install script
      "$script_install_path/$script_name" --uninstall
      "$script_install_path/$script_name" --install
      return 1
      ;;
    --verbose)
      verbose=true
      ;;
    *)
      # Collect the languages
      languages="$languages,$1"
      ;;
    esac
    shift
  done

  # trim the spaces in the languages and remove possible empty values
  languages="$(echo "$languages" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  languages="$(echo "$languages" | sed -e 's/,,/,/g')"
  languages="$(echo "$languages" | sed -e 's/,$//')"
  languages="$(echo "$languages" | sed -e 's/^,//')"
  # make the list of languages unique, need to refactor this eventually eheeeeeehee...
  languages="$(echo "$languages" | tr ',' '\n' | sort -u | tr '\n' ',')"
  languages="$(echo "$languages" | sed -e 's/,$//')"

  # check if the user want to use a custom template, if so, check if the template exists, if not, create it
  if [ "$use_template" = true ]; then
    if [ "$template_name" = "" ]; then
      template_name="default"
    fi
    if [ -f "$gitignore_template_path/$template_name" ] && [ "$overrite_template" = false ]; then
      echo "Using the template \"$template_name\"..."
      languages="$(cat "$gitignore_template_path/$template_name")"
    elif [ "$overrite_template" = true ]; then
      echo "Overwriting the template \"$template_name\"..."
      echo "$languages" >"$gitignore_template_path/$template_name"
    else
      echo "Creating the template \"$template_name\"..."
      mkdir -p "$gitignore_template_path"
      echo "$languages" >"$gitignore_template_path/$template_name"
    fi
  fi

  # fetch the list of available languages from the gitignore.io website or use the cached version if it exists and check if the last modified date is less than 3 days ago else refetch the list
  if [ ! -f "$gitignore_path" ] || [ $(($(date +%s) - $(date -r "$gitignore_path" +%s))) -gt 259200 ]; then
    echo "No local list of languages/frameworks/libraries found or the list is older than 3 days. Fetching the latest list..."
    # curl -sSL $gitignore_api_url/list >"$gitignore_path/available_gitignores"
    curl -sSL $gitignore_api_url/list >"$gitignore_path/available_gitignores"

    if [ $? -ne 0 ]; then

      echo "An error occurred while fetching the list of languages/frameworks/libraries."
      echo "It might be a temporary issue, please try again later."
      echo "You can always create a github issue at $script_website/issues"
      echo ""
    fi
  else
    echo "Using cached list of languages/frameworks/libraries..."
  fi

  list=$(cat "$gitignore_path/available_gitignores")
  # error handling
  if [ $? -ne 0 ]; then
    echo "An error occurred while fetching the list of languages/frameworks/libraries."
    echo "It might be a temporary issue, please try again later."
    echo "You can always create a github issue at $script_website/issues"
    echo ""
  fi

  # Check if the provided languages are valid and print an error message if not
  if [[ "$languages" != "" ]]; then
    # Check if the list is not empty before checking the languages
    if [ "$list" = "" ]; then
      echo "Could not fetch the list, thus we cannot affirm that the provided languages are valid." | sed -e 's/^/[90m/' -e 's/$/[0m/'
    else
      for language in $(echo "$languages" | sed "s/,/ /g"); do
        if [[ "$list" != *"$language"* ]]; then
          echo "$language is not a valid language/framework/library. Please check the list of available languages/frameworks/libraries using the -h or --help option."
        fi
      done
    fi
  fi

  content=""

  if [ "$use_template" = true ]; then
    # check if the template exists on the local machine
    # TODO: add a message to warn about possible missing permissions
    if [ -f "$gitignore_template_path/$template_name" ]; then
      # add the languages from the template to the list of languages, remove the first comma and trim the spaces, remove possible empty values, make sure the list is unique
      languages="$(echo "$languages,$(cat "$gitignore_template_path/$template_name")" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      languages="$(echo "$languages" | sed -e 's/,,/,/g')"
      languages="$(echo "$languages" | sed -e 's/^[,]*//' -e 's/[,]*$//')"
      languages="$(echo "$languages" | tr ',' '\n' | sort -u | tr '\n' ',')"

      # write back the languages to the template if overwrite is true
      # TODO: add a message to tell the user that the template has been updated
      if [ "$overrite_template" = true ]; then
        echo "$languages" >"$gitignore_template_path/$template_name"
      fi
    else
      echo "The template \"$template_name\" does not exist."
      echo "Please check that the template exists."
      echo "If you are on a Windows machine you could use dir $gitignore_template_path to see the list of templates."
      echo "If you are on a UNIX machine you could use ls -a $gitignore_template_path to see the list of templates."
    fi
  fi

  # Generate the gitignore file
  if [[ "$languages" == "" ]]; then
    echo "Generating a default gitignore file..."
    content=$(curl -sSL $gitignore_api_url)
    if [[ "$verbose" == true ]]; then
      echo "Requested URL: $gitignore_api_url"
    fi
  else
    echo "Generating a gitignore file for the following: $languages"
    if [[ "$verbose" == true ]]; then
      echo "Requested URL: $gitignore_api_url/$languages"
    fi
    content=$(curl -sSL "$gitignore_api_url/$languages")
  fi

  # Echo an overview of the selected languages and if they are found in the gitignore file
  if [[ "$languages" != "" ]]; then
    echo ""
    echo "Selected languages:"
    echo "-------------------"
    for language in $(echo $languages | tr ',' '\n'); do
      # case insensitive search
      if [[ $(echo $content | grep -i $language) ]]; then
        echo "$language"
      else
        echo "$language (not found)"
      fi
    done
  fi

  # Append to the existing file if requested
  if [[ "$append" == true ]]; then
    echo "Appending to the existing gitignore file..."
    echo "$content" >>"$output_file"
  else
    echo "Writing to the gitignore file..."
    echo "$content" >"$output_file"
  fi

}

# call the function
gitignore "$@"
# app lang switcher alfred workflow
Launch App in selected language, or set as Default language.

![usage demo](assets/usage-demo.gif)

*Credits*: This is a swift clone of [AlfredWorkflow-App-Language-Switcher](https://github.com/mpco/AlfredWorkflow-App-Language-Switcher) by [mpco](https://github.com/mpco). Due to the latest release of macOS 12.3, python2 has been removed, which broke the original workflow. So I reimplemented this workflow in Swift.

## Install
### Prepare
1. you should have unlocked [Powerpack in Alfred](https://www.alfredapp.com/powerpack/)
2. make sure you have `swift` available in terminal.(**If you have `Xcode` installed, you can skip this step.**):
   1. type `swift --version` in terminal, if you don't see any version info output, following next step to install it.
   2. type `xcode-select --install` in terminal to install swift cli tools


### Install

[download workflow](https://github.com/oe/app-lang-switcher-alfred-workflow/raw/main/AppLanguageSwitcher.alfredworkflow) then click the downloaded file to install

## Usage

1. choose a app in alfred
2. press `→` to enter file action menu
3. input `language` to enter language selection menu
4. search languages with their names, select a language then press `↵` to select language and launch the app. (*you may also press `cmd` + `enter` to set the selected language as default language*)


## Contributions and Support
I'm new to swift, feel free to make a pull request if you are willing to improve the code quality or its functions.

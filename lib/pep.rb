require "json"

module NeaHelpers
  def self.add_development_dependency(dependency_name)
    system("yarn add -D #{dependency_name}")
    system("yarn install")
  end

  def self.add_dependency(dependency_name)
    system("npx expo install #{dependency_name}")
  end

  def self.git_commit(with_message:)
    system("git add .")
    system("git commit -am '#{with_message}'")
  end

  def self.add_package_json_script(name:, script:)
    package_json = JSON.parse(File.read("package.json"))
    package_json["scripts"][name] = script
    File.open("package.json", "w+") do |file|
      file.write(JSON.pretty_generate(package_json) + "\n")
    end
  end
end

class CreateTypescriptExpoApp
  def self.create_typescript_expo_app(with_name:)
    new(with_name).create_typescript_expo_app
  end

  attr_reader :app_name

  def initialize(app_name)
    @app_name = app_name
  end

  def create_typescript_expo_app
    system("yarn create expo-app #{app_name} --template blank-typescript")
  end
end

class AddPrettier
  def self.add_prettier(to_app_with_name:)
    new(to_app_with_name).add_prettier
  end

  attr_reader :app_name

  def initialize(app_name)
    @app_name = app_name
  end

  def add_prettier
    Dir.chdir(app_name) do
      write_prettier_rc
      NeaHelpers.add_development_dependency("prettier")
      NeaHelpers.add_package_json_script(
        name: "prettier-check",
        script: "prettier --check './**/*.{ts,tsx}'",
      )
      NeaHelpers.add_package_json_script(
        name: "prettier-fix",
        script: "prettier --write './**/*.{ts,tsx}'",
      )
      system("yarn prettier-fix")
      NeaHelpers.git_commit(with_message: "Add prettier")
    end
  end

  private

  def write_prettier_rc
    File.open(".prettierrc", "w") do |prettier_rc|
      prettier_rc.write(prettier_rc_content)
    end
  end

  def prettier_rc_content
    <<~EOS
      {
        "printWidth": 80,
        "tabWidth": 2,
        "useTabs": false,
        "semi": false,
        "singleQuote": false,
        "quoteProps": "consistent",
        "jsxSingleQuote": false,
        "trailingComma": "all",
        "bracketSpacing": true,
        "bracketSameLine": false,
        "arrowParens": "avoid",
        "requirePragma": false,
        "insertPragma": false,
        "proseWrap": "preserve",
        "endOfLine": "lf",
        "embeddedLanguageFormatting": "auto",
        "singleAttributePerLine": false
      }
    EOS
  end
end

class ConfigureTypescript
  def self.configure_typescript(in_app_with_name:)
    new(in_app_with_name).configure_typescript
  end

  attr_reader :app_name

  def initialize(app_name)
    @app_name = app_name
  end

  def configure_typescript
    Dir.chdir(app_name) do
      update_tsconfig_json
      NeaHelpers.add_package_json_script(name: "tsc", script: "tsc")
      NeaHelpers.git_commit(with_message: "Configure typescript")
    end
  end

  private

  def update_tsconfig_json
    tsconfig_json = JSON.parse(File.read("tsconfig.json"))
    tsconfig_json_compiler_options.each do |name, value|
      tsconfig_json["compilerOptions"][name] = value
    end
    File.open("tsconfig.json", "w+") do |file|
      file.write(JSON.pretty_generate(tsconfig_json) + "\n")
    end
  end

  def tsconfig_json_compiler_options
    {
      "allowJs" => true,
      "esModuleInterop" => true,
      "jsx" => "react-native",
      "lib" => ["DOM", "ESNext"],
      "moduleResolution" => "node",
      "noEmit" => true,
      "resolveJsonModule" => true,
      "skipLibCheck" => true,
      "target" => "ESNext",
    }
  end
end

class AddEslint
  def self.add_eslint(to_app_with_name:)
    new(to_app_with_name).add_eslint
  end

  attr_reader :app_name

  def initialize(app_name)
    @app_name = app_name
  end

  def add_eslint
    Dir.chdir(app_name) do
      eslint_development_dependencies.each do |eslint_dev_dep|
        NeaHelpers.add_development_dependency(eslint_dev_dep)
      end
      File.open(".eslintrc.js", "w+") do |file|
        file.write(eslintrc_js_content)
      end
      NeaHelpers.add_package_json_script(
        name: "lint",
        script: "eslint '**/*.{ts,tsx}'",
      )
      NeaHelpers.git_commit(with_message: "Add eslint")
    end
  end

  private

  def eslint_development_dependencies
    [
      "@typescript-eslint/eslint-plugin",
      "@typescript-eslint/parser",
      "eslint",
      "eslint-plugin-react",
      "eslint-plugin-react-hooks",
      "eslint-plugin-react-native",
    ]
  end

  def eslintrc_js_content
    <<~EOS
    const rule = {
      off: 0,
      warn: 1,
      error: 2,
    }

    module.exports = {
      root: true,
      parser: "@typescript-eslint/parser",
      plugins: ["react", "react-native", "@typescript-eslint", "react-hooks"],
      extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
        project: "tsconfig.json",
      },
      env: {
        "react-native/react-native": true,
      },
      rules: {
        "react-native/no-unused-styles": rule.error,
        "react-native/split-platform-components": rule.error,
        "react-native/no-single-element-style-arrays": rule.error,
        "react-hooks/rules-of-hooks": "error",
        "react-hooks/exhaustive-deps": "error",
        "@typescript-eslint/switch-exhaustiveness-check": "error",
        "@typescript-eslint/ban-ts-comment": rule.off,
        "@typescript-eslint/no-empty-function": rule.off,
        "@typescript-eslint/explicit-function-return-type": "error",
        "@typescript-eslint/consistent-type-imports": "error",
      },
    }
    EOS
  end
end

class SetSrcAsRootDirectory
  def self.set_src_as_root_directory(in_app_with_name:)
    new(in_app_with_name).set_src_as_root_directory
  end

  attr_reader :app_name

  def initialize(app_name)
    @app_name = app_name
  end

  def set_src_as_root_directory
    Dir.chdir(app_name) do
      update_eslintrc
      update_babel_config_js
      move_app_tsx
      update_tsconfig_json
      NeaHelpers.git_commit(
        with_message: "Set /src as the root directory for app code",
      )
    end
  end

  private

  def update_tsconfig_json
    package_json = JSON.parse(File.read("tsconfig.json"))
    package_json["compilerOptions"]["baseUrl"] = "src"
    File.open("tsconfig.json", "w+") do |file|
      file.write(JSON.pretty_generate(package_json) + "\n")
    end
  end

  def move_app_tsx
    system("mkdir src")
    system("mv App.tsx src/")
    File.open("./App.tsx", "w+") do |file|
      file.write(
        <<~EOS
        import App from "App"

        export default App
        EOS
      )
    end
  end

  def update_babel_config_js
    new_content = new_babel_config_js_content
    File.open("babel.config.js", "w+") do |file|
      file.write(new_content)
    end
  end

  def new_babel_config_js_content
    current_lines = File.read("babel.config.js").split("\n")
    current_lines.inject([]) do |lines, current_line|
      if current_line == "  return {"
        lines + [current_line] + new_babel_config_js_lines
      else
        lines + [current_line]
      end
    end.join("\n") + "\n"
  end

  def new_babel_config_js_lines
    [
      "    plugins: [",
      "      [",
      "        \"module-resolver\",",
      "        {",
      "          root: [\"./src\"],",
      "          extensions: [\".ts\", \".tsx\"],",
      "        },",
      "      ],",
      "    ],",
    ]
  end

  def update_eslintrc
    new_content = new_eslintrc_content
    File.open(".eslintrc.js", "w+") do |file|
      file.write(new_content)
    end
  end

  def new_eslintrc_content
    current_lines = File.read(".eslintrc.js").split("\n")
    new_lines = (
      current_lines[0..-2] + new_eslintrc_lines + [current_lines[-1]]
    ).join("\n") + "\n"
  end

  def new_eslintrc_lines
    [
      "  settings: {",
      "    \"import/resolver\": {",
      "      node: {",
      "        paths: [\"src\"],",
      "      },",
      "    },",
      "  },",
    ]
  end
end

class InstallReactNavigation
  def self.install_react_navigation(in_app_with_name:)
    new(in_app_with_name).install_react_navigation
  end

  attr_reader :app_name

  def initialize(app_name)
    @app_name = app_name
  end

  def install_react_navigation
    Dir.chdir(app_name) do
      install_dependencies
      write_app_tsx
      NeaHelpers.git_commit(with_message: "Add react navigation")
    end
  end

  private

  def write_app_tsx
    File.open("./src/App.tsx", "w+") do |app_tsx|
      app_tsx.write(app_tsx_content)
    end
  end

  def install_dependencies
    [
      "@react-navigation/native",
      "react-native-screens",
      "react-native-safe-area-context",
      "@react-navigation/native-stack",
    ].each do |dep|
      NeaHelpers.add_dependency(dep)
    end
  end

  def app_tsx_content
    <<~EOS
    import { Button, Text, TextInput, View } from "react-native"
    import { DefaultTheme, NavigationContainer } from "@react-navigation/native"
    import { createNativeStackNavigator } from "@react-navigation/native-stack"
    import type { NativeStackScreenProps } from "@react-navigation/native-stack"
    import { useState } from "react"

    type StackNavigatorParams = {
      Home: undefined
      Details: { homeScreensTextInputValue: string }
    }

    type HomeProps = NativeStackScreenProps<StackNavigatorParams, "Home">
    type DetailsProps = NativeStackScreenProps<StackNavigatorParams, "Details">

    const HomeScreen = ({ navigation }: HomeProps): React.ReactElement => {
      const [homeScreensTextInputValue, setHomescreensTextInputValue] =
        useState<string>("")
      return (
        <View style={{ flex: 1, alignItems: "center" }}>
          <Text style={{ fontWeight: "bold", marginTop: 100, marginBottom: 100 }}>
            Open `src/App.tsx` to begin editing your app.
          </Text>
          <TextInput
            value={homeScreensTextInputValue}
            onChangeText={setHomescreensTextInputValue}
            placeholder="Type something here to see it on the details screen"
            style={{
              width: "90%",
              height: 30,
              textAlign: "center",
              borderWidth: 1,
              borderColor: "#aaa",
              marginTop: 20,
              marginBottom: 20,
            }}
          />
          <Button
            title="Go to Details Screen"
            onPress={(): void => {
              navigation.navigate("Details", { homeScreensTextInputValue })
            }}
          />
        </View>
      )
    }

    const DetailsScreen = ({ route }: DetailsProps): React.ReactElement => {
      const { homeScreensTextInputValue } = route.params
      return (
        <View style={{ flex: 1, alignItems: "center", paddingTop: 100 }}>
          <Text>Home Screen Text Says: {homeScreensTextInputValue}</Text>
        </View>
      )
    }

    const Stack = createNativeStackNavigator<StackNavigatorParams>()

    const MyTheme = {
      ...DefaultTheme,
      colors: {
        ...DefaultTheme.colors,
        background: "#fff",
      },
    }

    const App = (): React.ReactElement => (
      <NavigationContainer theme={MyTheme}>
        <Stack.Navigator>
          <Stack.Screen name="Home" component={HomeScreen} />
          <Stack.Screen name="Details" component={DetailsScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    )

    export default App
    EOS
  end
end

def run_pep(with_app_name:)
  app_name = with_app_name
  CreateTypescriptExpoApp.create_typescript_expo_app(with_name: app_name)
  AddPrettier.add_prettier(to_app_with_name: app_name)
  ConfigureTypescript.configure_typescript(in_app_with_name: app_name)
  AddEslint.add_eslint(to_app_with_name: app_name)
  SetSrcAsRootDirectory.set_src_as_root_directory(in_app_with_name: app_name)
  InstallReactNavigation.install_react_navigation(in_app_with_name: app_name)
end

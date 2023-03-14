<img src="https://i.imgur.com/80Fsp5f.gif" width="300"/>

# Pep

Begin your new expo app projects with some pep; that is, including:

* [Prettier](https://prettier.io)
* [Typescript](https://www.typescriptlang.org)
* [Eslint](https://eslint.org)
* [React Navigation](https://reactnavigation.org)
* Absolute imports relative to your `src/` directory

<img src="https://i.imgur.com/XlEyADo.png" width="650"/>

## Get Started

```sh
gem install pep
pep my-app-name # this will take a minute and you'll see yarn output
cd my-app-name
yarn start
```

Now, edit your `src/App.tsx` file.

## Defaults

Prettier, typescript, eslint, and react navigation are all added to your project and set up in discrete commits; The way you'd do it by hand if you spent the extra time.

**The best way to inspect the changes `pep` makes to a default Expo project is by creating a new project with `pep` and inspecting the project's git log**.

[Here is an example of what a project-created-with-pep's git log looks like (excluding the last commit which adds a readme to that project)](https://github.com/pachun/a-default-pep-app/commits/main).

We'll cover other ways to peek ahead and inspect the default configurations ahead of time, if that's your thing 😉

### Prettier

[You can view all the changes pep makes to add prettier to a default Expo project here](https://github.com/pachun/a-default-pep-app/commit/7fbc040b2b13cbb1aee85f55f1ea8559bc3e0d57).

[You can view the default prettier configuration here](https://github.com/pachun/Pep/blob/5c6e2661ddb25bc832d916cc13259ac3037ab2e6/lib/pep.rb#L79).

Once you've created a project with `pep`, you can view or edit the prettier configuration by opening the hidden dotfile named `.prettierrc`

### Eslint

[You can view all the changes pep makes to add eslint to a default Expo project here](https://github.com/pachun/a-default-pep-app/commit/8e9b6782a5e3ed78de0be09f5019d1bcff33938e).

[You can view the default eslint configuration here](https://github.com/pachun/Pep/blob/5c6e2661ddb25bc832d916cc13259ac3037ab2e6/lib/pep.rb#L190).

Once you've created a project with `pep`, you can view or edit the eslint configuration by opening the hidden dotfile named `.eslintrc.js`

### Typescript

[You can view all the changes pep makes to configure typescript in a default Expo project here](https://github.com/pachun/a-default-pep-app/commit/09b5de0b6b00727a23d8d0b824859dc55d04ea5e).

[You can view the default _changes_ made to expo's default typescript configuration here](https://github.com/pachun/Pep/blob/5c6e2661ddb25bc832d916cc13259ac3037ab2e6/lib/pep.rb#L135).

Once you've created a project with `pep`, you can view or edit the tyepscript configuration by opening the file named `tsconfig.json`

The default expo `tsconfig.json` combined with `pep`'s changes ([which are discussed in detail in Expo's docs here](https://docs.expo.dev/guides/typescript/#base-configuration)) generates the following `tsconfig.json` content:

```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "allowJs": true,
    "esModuleInterop": true,
    "jsx": "react-native",
    "lib": [
      "DOM",
      "ESNext"
    ],
    "moduleResolution": "node",
    "noEmit": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "target": "ESNext"
  }
}
```

### Absolute Imports

[You can view all the changes pep makes to add absolute imports to a default Expo project here](https://github.com/pachun/a-default-pep-app/commit/ef6af8d52eb86aa7f83cbc2343537426240c7561).

Once a new project is created with pep, you can always import code relative to the src/ directory.

... For Example ...

If you are importing the component in `src/components/FancyTextInput.tsx` from `src/screens/HomeScreen.tsx`, you can do so like this:

```typescript
import FancyTextInput from "components/FancyTextInput"
```

... Rather than doing it like this ...

```typescript
import FancyTextInput from "../components/FancyTextInput"
```

I've found this setting enables easier refactoring when copying and pasting import lines, and especially when moving files around.

The best way to view the changes that go into making this feature work is to inspect the commit titled "`Set /src as the root directory for app code`" after creating a new `pep` project.

The setup for this feature touches several configuration files, including: `.eslintrc.js`, `babel.config.js`, and `tsconfig.json`.

[You can skim through this class to get an idea of what exactly gets changed before creating a new project with pep](https://github.com/pachun/Pep/blob/5c6e2661ddb25bc832d916cc13259ac3037ab2e6/lib/pep.rb#L229).

### React Navigation

[You can view all the changes pep makes to add React Navigation to a default Expo project here](https://github.com/pachun/a-default-pep-app/commit/1d3825cb604f896f7a310a03cecd74cfe0474908).

Your default `src/App.tsx` file will look like this after setting up a new pep project:

```react
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
      <Text style={{ fontWeight: "bold", marginTop: 100 }}>
        Open `src/App.tsx` to begin editing your app.
      </Text>
      <Text style={{ marginTop: 100 }}>Home Screen</Text>
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
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Text>Details Screen says: {homeScreensTextInputValue}</Text>
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
```

Something I really value about this setup (in addition to it setting up react navigation) is the effort that goes into making clear how to use react navigation in a way that makes typescript happy; eg everything which uses this type definition:

```typescript
type StackNavigatorParams = {
  Home: undefined
  Details: { homeScreensTextInputValue: string }
}
```

Which includes the creation of the stack navigator ...

```typescript
const Stack = createNativeStackNavigator<StackNavigatorParams>()
```

... As well as the creation of a type for the top level screens's component props ...

```typescript
import type { NativeStackScreenProps } from "@react-navigation/native-stack"

// ...

type HomeProps = NativeStackScreenProps<StackNavigatorParams, "Home">
type DetailsProps = NativeStackScreenProps<StackNavigatorParams, "Details">

const HomeScreen = ({ navigation }: HomeProps): React.ReactElement => {
  // ...
  return (
    // ...
    <Button
      title="Go to Details Screen"
      onPress={(): void => {
        navigation.navigate("Details", { homeScreensTextInputValue })
      }}
    />
    // ...
  )
}

const DetailsScreen = ({ route }: DetailsProps): React.ReactElement => {
  const { homeScreensTextInputValue } = route.params
  return (
    <View style={{ flex: 1, alignItems: "center", justifyContent: "center" }}>
      <Text>Details Screen says: {homeScreensTextInputValue}</Text>
    </View>
  )
}
```

... Which is needed to tell typescript where the `navigation` and `route` props come from, as well as which route params each screen expects passed to it, like above with the line ...

```
const { homeScreensTextInputValue } = route.params
```

[Every time I go to setup React Navigation, it's been long enough since the last time that I did it that I have to go back and re-read the docs over here](https://reactnavigation.org/docs/typescript/).

Pep also creates a custom React Navigation theme and applies it:

```typescript
import { DefaultTheme } from "@react-navigation/native"

const MyTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    background: "#fff",
  },
}

const App = (): React.ReactElement => (
  <NavigationContainer theme={MyTheme}>
    // ...
  </NavigationContainer>
)
```

The only thing which `pep` actually changes here is the default screen background colors, which it sets to white because React Navigation defaults screen background colors to a slightly off-gray color which I find myself also consistently looking back in the docs for how to switch that back to white.

# 💃

I hope this peppy little automation saves you some time, too!

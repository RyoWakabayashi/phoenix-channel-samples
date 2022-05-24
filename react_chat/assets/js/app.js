import "../css/app.css"

import "phoenix_html";
import React, { useState } from "react";
import ReactDOM from "react-dom";
import { Auth0Provider, useAuth0 } from "@auth0/auth0-react";
import lightBaseTheme from 'material-ui/styles/baseThemes/lightBaseTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import getMuiTheme from 'material-ui/styles/getMuiTheme';

import Chat from "./Chat";

function App() {
  const { isAuthenticated, loginWithRedirect, getIdTokenClaims, user, logout } = useAuth0()
  const [idToken, setIdToken] = useState("")

  if (isAuthenticated && idToken === "") {
    getIdTokenClaims().then((token) => {
      if (token) {
        setIdToken(token.__raw)
      }
    })
  }

  if (isAuthenticated && idToken !== "") {
    return (
      <div>
        <Chat userName={user.name} idToken={idToken}/>
        <button onClick={() => logout({ returnTo: window.location.origin })}>
          Log out
        </button>
      </div>
    );
  } else {
    return <button onClick={loginWithRedirect}>Log in</button>
  }
}

const target = document.getElementById('app');
const node =(
  <Auth0Provider
    domain={PUBLIC_CONFIGS.domain}
    clientId={PUBLIC_CONFIGS.client_id}
    redirectUri={window.location.origin}
  >
    <MuiThemeProvider muiTheme={getMuiTheme(lightBaseTheme)}>
      <App />
    </MuiThemeProvider>
  </Auth0Provider>
);

ReactDOM.render( node, target )

import '@mantine/core/styles.css';
import '@mantine/notifications/styles.css';
import '@tronweb3/tronwallet-adapter-react-ui/style.css';
import './main.css';

import { MantineProvider } from '@mantine/core';
import { Notifications } from '@mantine/notifications';
import { Router } from './Router';
import { theme } from './theme';

import { WalletProvider } from '@tronweb3/tronwallet-adapter-react-hooks';
import { WalletModalProvider } from '@tronweb3/tronwallet-adapter-react-ui';


export default function App() {
  function onError(e: any) {
    console.error(e);
  }

  return (
    <MantineProvider defaultColorScheme="dark" theme={theme}>
      <WalletProvider
        onError={onError}
        autoConnect={true}
      >
        <WalletModalProvider>
          <Notifications />
          <Router />
        </WalletModalProvider>
      </WalletProvider>
    </MantineProvider>
  );
}

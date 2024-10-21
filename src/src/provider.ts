// @ts-ignore
import TronWeb from 'tronweb';

const TOKEN = "fwdo03vv4bvofu4m84twnmhovk8vdg";
const tronWeb = new TronWeb({
    fullHost: `https://${TOKEN}.nile.tron.tronql.com/`,
    eventServer: `https://${TOKEN}.nile.tron.tronql.com/`
  }
)

export default tronWeb;

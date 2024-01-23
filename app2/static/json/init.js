import styles from './styles/styles.js';


styles();




import init from "./utils/helpers/init.js";
import update from "./utils/helpers/update.js";
import interaction from "./utils/helpers/interaction.js";
import { route } from "./utils/Route.js";

init();
update(route.HOME);
interaction();
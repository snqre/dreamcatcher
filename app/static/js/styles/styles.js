import flickerPattern1KeyframesStyle from './animations/enter/flickerPattern1KeyframesStyle.js';
import flickerPattern1With0000msDelayStyle from './animations/enter/flickerPattern1With0000msDelayStyle.js';
import flickerPattern1With0100msDelayStyle from './animations/enter/flickerPattern1With0100msDelayStyle.js';
import flickerPattern1With0200msDelayStyle from './animations/enter/flickerPattern1With0200msDelayStyle.js';
import flickerPattern1With0300msDelayStyle from './animations/enter/flickerPattern1With0300msDelayStyle.js';
import flickerPattern1With0400msDelayStyle from './animations/enter/flickerPattern1With0400msDelayStyle.js';
import flickerPattern1With0500msDelayStyle from './animations/enter/flickerPattern1With0500msDelayStyle.js';
import flickerPattern1With0600msDelayStyle from './animations/enter/flickerPattern1With0600msDelayStyle.js';
import flickerPattern1With0700msDelayStyle from './animations/enter/flickerPattern1With0700msDelayStyle.js';
import flickerPattern1With0800msDelayStyle from './animations/enter/flickerPattern1With0800msDelayStyle.js';
import flickerPattern1With0900msDelayStyle from './animations/enter/flickerPattern1With0900msDelayStyle.js';
import flickerPattern1With1000msDelayStyle from './animations/enter/flickerPattern1With1000msDelayStyle.js';

import bodyBaseStyle from './basic/base/bodyBaseStyle.js';
import contentBaseStyle from './basic/base/contentBaseStyle.js';
import everythingBaseStyle from './basic/base/everythingBaseStyle.js';
import headerBaseStyle from './basic/base/headerBaseStyle.js';
import scrollbarBaseStyle from './basic/base/scrollbarBaseStyle.js';

import columnStyle from './basic/flex/containers/columnStyle.js';
import rowStyle from './basic/flex/containers/rowStyle.js';

import flex1Style from './basic/flex/flex1Style.js';
import flex2Style from './basic/flex/flex2Style.js';
import flex3Style from './basic/flex/flex3Style.js';
import flex4Style from './basic/flex/flex4Style.js';
import flex5Style from './basic/flex/flex5Style.js';
import flex6Style from './basic/flex/flex6Style.js';
import flex7Style from './basic/flex/flex7Style.js';
import flex8Style from './basic/flex/flex8Style.js';
import flex9Style from './basic/flex/flex9Style.js';

import button29Style from './buttons/button29Style.js';
import button30Style from './buttons/button30Style.js';
import button49Style from './buttons/button49Style.js';
import button54Style from './buttons/button54Style.js';
import button57Style from './buttons/button57Style.js';
import button64Style from './buttons/button64Style.js';

export default function styles() {
    head().attach([
        flickerPattern1KeyframesStyle(),
        flickerPattern1With0000msDelayStyle(),
        flickerPattern1With0100msDelayStyle(),
        flickerPattern1With0200msDelayStyle(),
        flickerPattern1With0300msDelayStyle(),
        flickerPattern1With0400msDelayStyle(),
        flickerPattern1With0500msDelayStyle(),
        flickerPattern1With0600msDelayStyle(),
        flickerPattern1With0700msDelayStyle(),
        flickerPattern1With0800msDelayStyle(),
        flickerPattern1With0900msDelayStyle(),
        flickerPattern1With1000msDelayStyle(),
        bodyBaseStyle(),
        contentBaseStyle(),
        everythingBaseStyle(),
        headerBaseStyle(),
        scrollbarBaseStyle(),
        columnStyle(),
        rowStyle(),
        flex1Style(),
        flex2Style(),
        flex3Style(),
        flex4Style(),
        flex5Style(),
        flex6Style(),
        flex7Style(),
        flex8Style(),
        flex9Style(),
        button29Style(),
        button30Style(),
        button49Style(),
        button54Style(),
        button57Style(),
        button64Style()
    ]);
}
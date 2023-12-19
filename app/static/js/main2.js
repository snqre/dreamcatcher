import Block from './Block.js';
import GridBlock from './components/grid/Grid.js';
import GridItemBlock from './components/grid/GridItemBlock2.js';

let brandColor  = '#5606FE';
let backgroundColor = '#121212';

const headBlock = new Block();
headBlock.representElementObjectHTML('head');

    const scrollbarStyleBlock = new Block();
    scrollbarStyleBlock.generateElementObjectHTML('style');
    scrollbarStyleBlock.injectSourceCodeHTML('::-webkit-scrollbar { width: 5px; }');
    scrollbarStyleBlock.injectSourceCodeHTML(`::-webkit-scrollbar-track { background: ${backgroundColor}; }`);
    scrollbarStyleBlock.injectSourceCodeHTML(`::-webkit-scrollbar-thumb { background: ${brandColor}; }`);
    headBlock.injectBlock(scrollbarStyleBlock);

const everyBlock = new Block();
everyBlock.representElementObjectHTML('*');
everyBlock.noMargin();
everyBlock.noPadding();
everyBlock.assignStyle({boxSizing: 'border-box'});

const bodyBlock = new Block();
bodyBlock.representElementObjectHTML('body');
bodyBlock.assignStyle({background: `${backgroundColor}`});
bodyBlock.assignStyle({color: '#FFF'});
    
    const headerBlock = new Block();
    headerBlock.generateElementObjectHTML('header');
    headerBlock.fillScreen();
    headerBlock.assignStyle({position: 'fixed'});
    headerBlock.hideOverflow();
    headerBlock.assignStyle({zIndex: '200000'});
    headerBlock.disablePointerEvents();
    bodyBlock.injectBlock(headerBlock);

    const contentBlock = new Block();
    contentBlock.generateElementObjectHTML('content');
    contentBlock.assignStyle({width: '100%'});
    contentBlock.assignStyle({height: '500vh'});
    contentBlock.assignStyle({position: 'absolute'});
    contentBlock.hideOverflow();
    bodyBlock.injectBlock(contentBlock);

        contentBlock.reset();

        const section = new GridBlock();
        section.fillWidth();
        section.assignStyle({height: '80vh'});
        section.assignColumnsCount(12);
        section.assignRowsCount(6);
        contentBlock.injectBlock(section);

            const con = new GridItemBlock();
            con.generateElementObjectHTML('img');
            con.assignCoordinates(3, 7, 3, 4);
            section.injectBlock(con);
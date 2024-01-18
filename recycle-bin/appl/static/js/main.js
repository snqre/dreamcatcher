import Velvet from './velvet-framework/velvet-framework';

let _ = new Velvet();

let index = _.Disk()
    .pushSections([
        _
            .template()
            .dynamicContent({
            
        }),
        _
            .Disk()
            
    ])
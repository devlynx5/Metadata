public class MetadataController {
    
    static String toolingAPISOQL(string query) {
        String baseURL='callout:ToolingRest?';
        return HttpCallout.restGet( baseURL +'q='+ (query.replace(' ', '+')),'GET', UserInfo.getSessionId());
    } 
    @AuraEnabled(cacheable=true)
    public static List<DependentInfo.Record> getDepdency() {
       String searchKey ;
      
        string sql='Select MetadataComponentId, MetadataComponentName, RefMetadataComponentType,RefMetadataComponentName, RefMetadataComponentId,MetadataComponentType from MetadataComponentDependency' ;

        //WHERE RefMetadataComponentType ='+ '\''+ searchKey + '\''
        system.debug('sql---'+sql);

        if ( searchKey != null && searchKey != '' ) {
            sql += ' WHERE RefMetadataComponentType =' + '\''+ searchKey + '\'';
        
        }
       
        String result = toolingAPISOQL(sql);
        if(string.isNotBlank(result))
        {
            DependentInfo data=DependentInfo.parse(result);
            return data.records;
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static List<TreeNode> getMetadata()
    {
        Set<string> metaSet = new Set<string>();
        List<DependentInfo.Record> records=getDepdency();
        
        List<TreeNode> nodes=new List<TreeNode>();
        for(DependentInfo.Record record:records)
        {
            if(!metaSet.contains(record.MetadataComponentId))
            {  
                TreeNode node=new TreeNode();
                node.MetadataComponentName=record.MetadataComponentName;
                node.RefMetadataComponentName=record.RefMetadataComponentName;
                node.MetadataComponentType=record.MetadataComponentType;
                node.RefMetadataComponentId=record.RefMetadataComponentId;
                node.MetadataComponentId=record.MetadataComponentId;
                node.RefMetadataComponentType=record.RefMetadataComponentType;
                if(records.size()>0)
                {
                    List<TreeNode> childs=new List<TreeNode>();
                    for(DependentInfo.Record rd:records)
                    {
                        if(rd.MetadataComponentId==record.MetadataComponentId)
                        {
                            TreeNode chNode=new TreeNode();
                            chNode.MetadataComponentName=rd.MetadataComponentName;
                            chNode.RefMetadataComponentName=rd.RefMetadataComponentName;
                            chNode.RefMetadataComponentType=rd.RefMetadataComponentType;
                            chNode.MetadataComponentType=rd.MetadataComponentType;
                            chNode.RefMetadataComponentId=rd.RefMetadataComponentId;
                            chNode.MetadataComponentId=rd.MetadataComponentId;
                            childs.add(chNode);
                        }
                    }
                    if(childs.size()>=0)
                    {
                        node.children=childs;
                        node.MetadataComponentName=record.MetadataComponentName;
                        node.MetadataComponentType='';
                        node.RefMetadataComponentId='';
                        node.RefMetadataComponentType='';
                        node.RefMetadataComponentName='';
                        node.MetadataComponentId=record.MetadataComponentId;
                    }
                }
                metaSet.add(record.MetadataComponentId);
                nodes.add(node);
            }
        }
        return nodes;
    }
    
    public class TreeNode {
        @AuraEnabled
        public String MetadataComponentId {get;set;} 
        @AuraEnabled
        public String MetadataComponentName {get;set;} 
        @AuraEnabled
        public String RefMetadataComponentName {get;set;} 
        @AuraEnabled
        public String RefMetadataComponentId {get;set;} 
        @AuraEnabled
        public String MetadataComponentType {get;set;} 
        @AuraEnabled
        public String RefMetadataComponentType {get;set;} 
        @AuraEnabled
        public List<TreeNode> children { get; set; } 
    }
}
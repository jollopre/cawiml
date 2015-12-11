<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xml:lang="en">
    <title>Schematron rules for Survey State Model (SSM)</title>
    <ns uri="http://www.surveysm.com" prefix="ssm"></ns>
        <!-- 
        *
        *
        *   ROUTING SECTION RULES
        *
        *
        *
        !-->
    <pattern id="statemodel">
        <rule context="ssm:statemodel">
            <let name="statemodel" value="."/>
            <assert test="exists(//ssm:section[@id = $statemodel/@ref])" diagnostics="m00"></assert>
            <assert test="count(preceding-sibling::*[@ref = $statemodel/@ref]) = 0" diagnostics="m01"></assert>
        </rule>
    </pattern>
    <pattern id="source">
        <rule context="ssm:source">
            <let name="source" value="."/>
            <assert test="exists(following-sibling::*[@id = $source/@id])" diagnostics="m10"></assert>
        </rule>
    </pattern>
    <pattern id="state">
        <rule context="ssm:state">
            <let name="state" value="."/> 
            <assert test="string-length(./@id)>0" diagnostics="m20"></assert>
            <assert test="not(exists(preceding-sibling::*[local-name() = 'state'][@id = $state/@id]))" diagnostics="m21"></assert>
        </rule>
    </pattern>
    <pattern id="transition">
        <rule context="ssm:transition">
            <let name="transition" value="."/>
            <assert test="string-length(./@target)>0" diagnostics="m30"></assert>
            <assert test="exists(ancestor::ssm:state/preceding-sibling::ssm:state[@id = $transition/@target]) or
                          exists(ancestor::ssm:state/following-sibling::ssm:state[@id = $transition/@target])" diagnostics="m31"></assert>
            <assert test="not(ancestor::ssm:state/@id  = $transition/@target)" diagnostics="m32"></assert>
        </rule>
    </pattern>
    <pattern id="include">
        <rule context="ssm:include">
            <let name="include" value="."/>
            <assert test="string-length(./@statemodel)>0" diagnostics="m40"></assert>
            <assert test="exists(ancestor::ssm:routing/ssm:statemodel[@ref = $include/@statemodel])" diagnostics="m41"></assert>
        </rule>
    </pattern>
    <pattern id="for">
        <rule context="ssm:for/ssm:transition">
            <let name="transition" value="."/>
            <assert test="exists(ancestor::ssm:state/preceding-sibling::ssm:state[@id=$transition/@target]) or
                          exists(ancestor::ssm:state/following-sibling::ssm:state[@id=$transition/@target])" diagnostics="m50"></assert>
        </rule>
        <rule context="ssm:for/ssm:field">
            <let name="iterator" value="."/>
            <assert test="string-length(./@ref)>0" diagnostics="m52"></assert>
            <assert test="exists(ancestor::ssm:ssm/ssm:field/ssm:iterator[@id = $iterator/@ref])" diagnostics="m53"></assert>
        </rule>
        <rule context="ssm:for/ssm:in/ssm:range/child::*/ssm:variable">
            <let name="statemodel" value="ancestor::ssm:statemodel"/>
            <let name="variable" value="."/>
            <assert test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:open[@name = $variable/@ref]/ssm:integer) or
                          exists(ancestor::ssm:ssm/ssm:field/ssm:integer[@id = $variable/@ref])" diagnostics="m51"></assert>
        </rule>
        <rule context="ssm:for/ssm:in/ssm:list">
            <let name="list" value="."/>
            <assert test="exists(ancestor::ssm:ssm/ssm:field/ssm:list[@name = $list/@ref])" diagnostics="m54"></assert>
        </rule>
    </pattern>
    <pattern id="composite">
        <rule context="ssm:state">
            <let name="state" value="."/>
            <assert test="if(exists(child::ssm:include) and not(exists(child::ssm:transition))) then
                          exists(preceding-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]) or
                          exists(following-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id])
                          else true()" diagnostics="m22">  
            </assert>
            <assert test="if(exists(child::ssm:include) and exists(child::ssm:transition)) then
                not(exists(preceding-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]) or
                exists(following-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]))
                else true()" diagnostics="m23">
            </assert>
        </rule>
    </pattern>
    <pattern id="variable">
        <rule context="ssm:state/ssm:variable">
            <let name="statemodel" value="ancestor::ssm:statemodel"/>
            <let name="variable" value="."/>
            <assert test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref])) 
                          then true()
                          else false()" diagnostics="m60">
            </assert>
        </rule>
        <rule context="ssm:state//ssm:variable">
            <let name="statemodel" value="ancestor::ssm:statemodel"/>
            <let name="variable" value="."/>
            <assert test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref])) 
                then true()
                else if(exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref])) 
                then true() 
                else false()" diagnostics="m61">
            </assert>
        </rule>
        <rule context="ssm:pipe//ssm:variable">
            <let name="piping" value="ancestor::ssm:piping"/>
            <let name="variable" value="."/>
            <assert test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $piping/@ref]/child::*[@name = $variable/@ref])) 
                then true()
                else if(exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref])) 
                then true() 
                else false()" diagnostics="m61">
            </assert>
        </rule>
    </pattern>
    <pattern id="multivariable">
        <rule context="ssm:state//ssm:multivariable">
            <let name="statemodel" value="ancestor::ssm:statemodel"/>
            <let name="multivariable" value="."/>
            <assert test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref])) 
                then true()
                else false()" diagnostics="m62">
            </assert>
            <assert test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/*/ssm:rows/child::*[@code = $multivariable/@row]))
                then true()
                else false()" diagnostics="m63">
            </assert>
            <assert test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/ssm:numeric))
                then exists($multivariable/@column)
                else true()" diagnostics="m64"></assert>
            <assert test="if(exists($multivariable/@column)) 
                            then if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/ssm:numeric/ssm:columns/child::*[@code = $multivariable/@column]))
                                    then true()
                                    else false()
                            else true()" diagnostics="m65">
            </assert>
        </rule>    
    </pattern>
    <pattern id="computation">
        <rule context="ssm:computation">
            <let name="variable" value="."/>
            <assert test="exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref])" diagnostics="m70">  
            </assert>
        </rule>
    </pattern>
    <pattern id="parameter">
        <rule context="ssm:parameter">
            <let name="statemodel" value="ancestor::ssm:statemodel"/>
            <let name="section" value="ancestor::ssm:section"/>
            <let name="variable" value="preceding-sibling::*[name() eq 'variable']"/>
            <assert test="exists(preceding-sibling::*[name() eq 'variable'])" diagnostics="m80">
            </assert>
            <assert test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref][name() eq 'matrix'])
                       or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref][name() eq 'form'])
                       or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref][name() eq 'matrix'])
                       or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref][name() eq 'form'])" diagnostics="m81">
            </assert>
        </rule>
        <rule context="ssm:parameter/ssm:matrix">
            <let name="statemodel" value="ancestor::ssm:statemodel"/>
            <let name="section" value="ancestor::ssm:section"/>
            <let name="variable" value="parent::*/preceding-sibling::*[name() eq 'variable']"/>
            <let name="matrix" value="."/>
            <assert test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]/*/ssm:row[@name = $matrix/@row])
                       or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref]/*/ssm:row[@name = $matrix/@row])" diagnostics="m82">
            </assert>
            <assert test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]/*/ssm:column[@name = $matrix/@column])
                or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref]/*/ssm:column[@name = $matrix/@column])" diagnostics="m83">
            </assert>
        </rule>
    </pattern>
    <!-- 
        *
        *
        *   PERSONALISATION SECTION RULES
        *
        *
        *
        !-->
    <pattern id="piping">
        <rule context="ssm:piping">
            <let name="piping" value="."/>
            <assert test="exists(//ssm:section[@id = $piping/@ref])" diagnostics="m500"></assert>
            <assert test="count(preceding-sibling::ssm:piping[@ref = $piping/@ref]) = 0" diagnostics="m501"></assert>
        </rule>
    </pattern>
    <pattern id="pipe">
        <rule context="ssm:pipe">
            <let name="pipe" value="."/>
            <let name="section" value="ancestor::ssm:section"/>
            <assert test="if(boolean(@id)) then string-length(./@id)>0 else true()" diagnostics="m510"></assert>
            <assert test="if(boolean(@id)) then count(preceding-sibling::*[@id = $pipe/@id]) = 0 else true()" diagnostics="m511"></assert>
            <assert test="if(boolean(@ref)) then exists(//ssm:piping[@ref = $section/@id]/ssm:pipe[@id = $pipe/@ref]) else true()" diagnostics="m512"></assert>        
        </rule>
    </pattern>
    <pattern id="displaying">
        <rule context="ssm:displaying">
            <let name="displaying" value="."/>
            <assert test="exists(//ssm:section[@id = $displaying/@ref])" diagnostics="m600"></assert>
            <assert test="count(preceding-sibling::ssm:displaying[@ref = $displaying/@ref]) = 0" diagnostics="m601"></assert>
        </rule>
    </pattern>
    <pattern id="display">
        <rule context="ssm:display">
            <let name="display" value="."/>
            <let name="section" value="ancestor::ssm:section"/>
            <assert test="if(boolean(@id)) then string-length(./@id)>0 else true()" diagnostics="m610"></assert>
            <assert test="if(boolean(@id)) then count(preceding-sibling::*[@id = $display/@id]) = 0 else true()" diagnostics="m611"></assert>
            <assert test="if(boolean(@ref)) then exists(//ssm:displaying[@ref = $section/@id]/ssm:display[@id = $display/@ref]) else true()" diagnostics="m612"></assert>        
        </rule>
    </pattern>
    <pattern id="subset_code">
        <rule context="ssm:subset/ssm:code">
            <let name="code" value="."/>
            <assert test="count(preceding-sibling::ssm:code[@ref = $code/@ref]) = 0" diagnostics="m700"></assert>
            <assert test="exists(parent::*/parent::*/following-sibling::*[@code = $code/@ref])" diagnostics="m701"></assert>
        </rule>
    </pattern>
        <!-- 
        *
        *
        *   CONTENT SECTION RULES
        *
        *
        *
        !-->
    <pattern id="section">
        <rule context="ssm:section">
            <let name="section" value="."/>
            <assert test="count(preceding-sibling::*[@id = $section/@id]) = 0" diagnostics="m200"></assert>
        </rule>
    </pattern>
    <pattern id="label">
        <rule context="ssm:label">
            <assert test="string-length(.)>0" diagnostics="m210"></assert>    
        </rule>
    </pattern>
    <pattern id="close">
        <rule context="ssm:close">
            <let name="response" value="."/>
            <assert test="count(preceding-sibling::*[@code = $response/@code]) = 0" diagnostics="m220"></assert>    
        </rule>
    </pattern>
    <pattern id="open">
        <rule context="ssm:open">
            <let name="response" value="."/>
            <assert test="if (not(exists(parent::ssm:section))) then 
                          count(preceding-sibling::*[@code = $response/@code]) = 0
                          else true()" diagnostics="m230">
            </assert>
            <!-- if any preceding sibling is group, check children names -->
            <assert test="if (not(exists(parent::ssm:section))) then
                          count(preceding-sibling::*[local-name() = 'group']/child::*[@code = $response/@code]) = 0
                          else true()" diagnostics="m230">
            </assert>
            <!-- if children parent is group check preceding siblings of the parent -->
            <assert test="if (exists(parent::ssm:group)) then
                          count(parent::node()/preceding-sibling::*[@code = $response/@code]) = 0 and
                          count(parent::node()/preceding-sibling::*[local-name() = 'group']/child::*[@code = $response/@code]) = 0
                          else true()">
            </assert>
        </rule>
    </pattern>
    <pattern id="question">
        <rule context="ssm:section/child::*">
            <let name="name" value="./@name"/>
            <assert test="count(preceding-sibling::*[@name = $name]) = 0" diagnostics="m240"></assert>
        </rule>
    </pattern>
    <pattern id="row">
        <rule context="ssm:row">
            <let name="row" value="."/>
            <assert test="count(preceding-sibling::*[@name = $row/@name]) = 0" diagnostics="m260"></assert>
        </rule>
    </pattern>
    <pattern id="column">
        <rule context="ssm:column">
            <let name="column" value="."/>
            <assert test="count(preceding-sibling::*[local-name() ne 'row'][@name = $column/@name]) = 0" diagnostics="m270"></assert>
        </rule>
    </pattern>
    <pattern id="constant">
        <rule context="ssm:constant">
            <assert test="if (@type eq 'integer') then
                if (@value castable as xs:integer) then true() else false()
                else true()" diagnostics="m250"></assert>
            <assert test="if (@type eq 'string') then
                if (@value castable as xs:string) then true() else false()
                else true()" diagnostics="m251"></assert>
            <assert test="if (@type eq 'decimal') then
                if (@value castable as xs:decimal) then true() else false()
                else true()" diagnostics="m252"></assert>
            <assert test="if (@type eq 'boolean') then
                if (@value castable as xs:boolean) then true() else false()
                else true()" diagnostics="m253"></assert>
        </rule>
    </pattern>
    <pattern id="min">
        <rule context="ssm:min">
            <assert test="if (not(empty(./text()))) then
                            if (not(empty(./following-sibling::ssm:max/text()))) then
                            boolean(number(./text()) &lt;= number(./following-sibling::ssm:max/text()))
                            else true()
                          else true()" diagnostics="m254">
            </assert>
        </rule>
    </pattern>
    <pattern id="value">
        <rule context="ssm:value">                  
            <assert test="if (not(empty(./preceding-sibling::ssm:min/text()))) then                 
                if (not(empty(./text()))) then boolean(number(./text()) &gt;= number(./preceding-sibling::ssm:min/text())) else true()
                          else true()" diagnostics="m255">
            </assert>
            <assert test="if (not(empty(./preceding-sibling::ssm:max/text()))) then
                          if (not(empty(./text()))) then boolean(number(./text()) &lt;= number(./preceding-sibling::ssm:max/text())) else true()
                          else true()" diagnostics="m256">
            </assert>
        </rule>
    </pattern>
        <!-- 
        *
        *
        *   FIELD SECTION RULES
        *
        *
        *
        !-->
    <pattern id="field">
        <rule context="ssm:field/child::*">
            <let name="field" value="."/>
            <assert test="count(preceding-sibling::*[@id = $field/@id]) = 0" diagnostics="m400"></assert>
        </rule>
    </pattern>
    <diagnostics>
        <!-- 
        *
        *
        *   ROUTING MESSAGES
        *
        *
        *
        !-->
        <!-- statemodel messages -->
        <diagnostic id="m00" xml:lang="en">
            statemodel: ref attribute must reference to a section defined in content context.
        </diagnostic>
        <diagnostic id="m01" xml:lang="en">
            statemodel: ref attribute is unique for the routing context.
        </diagnostic>
        <!-- initial messages -->
        <diagnostic id="m10" xml:lang="en">
            source: id attribute must reference to a state defined in the current statemodel.
        </diagnostic>
        <!-- state messages -->
        <diagnostic id="m20" xml:lang="en">
            state: id attribute must not be empty.
        </diagnostic>
        <diagnostic id="m21" xml:lang="en">
            state: id attribute is unique for the current statemodel. 
        </diagnostic>
        <diagnostic id="m22" xml:lang="en">
            state: transition is required for composite state.
        </diagnostic>
        <diagnostic id="m23" xml:lang="en">
            state: transition is forbidden because this state is target of a FOR state.
        </diagnostic>
        <!-- transition messages -->
        <diagnostic id="m30" xml:lang="en">
            transition: target attribute must not be empty.
        </diagnostic>
        <diagnostic id="m31" xml:lang="en">
            transition: target attribute must reference to a state defined in the current statemodel.
        </diagnostic>
        <diagnostic id="m32" xml:lang="en">
            transition: target attribute must not reference to itself because it creates a loop.
        </diagnostic>
        <!-- include messages -->
        <diagnostic id="m40" xml:lang="en">
            include: statemodel attribute must not be empty.
        </diagnostic>
        <diagnostic id="m41" xml:lang="en">
            include: statemodel attribute must reference to a statemodel defined in routing context.
        </diagnostic>
        <!-- for messages -->
        <diagnostic id="m50" xml:lang="en">
            transition: target attribute must reference to a composite state. 
        </diagnostic>
        <diagnostic id="m51" xml:lang="en">
            variable: ref attribute must reference to an open integer question or an integer variable 
            defined in field context.
        </diagnostic>
        <diagnostic id="m52" xml:lang="en">
            variable: ref attribute must not be empty
        </diagnostic>
        <diagnostic id="m53" xml:lang="en">
            variable: ref attribute must reference to a iterator variable defined in field context.
        </diagnostic>
        <diagnostic id="m54" xml:lang="en">
            list: ref attribute must reference to a list variable defined in field context.
        </diagnostic>
        <!-- variable messages -->
        <diagnostic id="m60" xml:lang="en">
            variable: ref attribute must reference to a question defined in the section.
        </diagnostic>
        <diagnostic id="m61" xml:lang="en">
            variable: ref attribute must reference to a question or a field.
        </diagnostic>
        <!-- multivariable messages -->
        <diagnostic id="m62">
            multivariable: ref attribute must reference to a grid question.
        </diagnostic>
        <diagnostic id="m63">
            multivariable: row attribute must reference to a grid question's row.
        </diagnostic>
        <diagnostic id="m64">
            multivariable: column attribute is expected for a numeric grid question
        </diagnostic>
        <diagnostic id="m65">
            multivariable: column attribute must reference to a numeric grid question's column.
        </diagnostic>
        <!-- computation messages -->
        <diagnostic id="m70" xml:lang="en">
            computation: ref attribute must reference to a field. 
        </diagnostic>
        <!-- parameter messages -->
        <diagnostic id="m80" xml:lang="en">
            parameter: variable is expected as preceding-sibling
        </diagnostic>
        <diagnostic id="m81" xml:lang="en">
            parameter: is allowed for matrix and form variables.
        </diagnostic>
        <diagnostic id="m82" xml:lang="en">
            parameter/matrix: row referenced does not exists for the variable. 
        </diagnostic>
        <diagnostic id="m83" xml:lang="en">
            parameter/matrix: column referenced does not exists for the variable. 
        </diagnostic>
        <diagnostic id="m84" xml:lang="en">
            parameter/form: field referenced does not exists for the variable.
        </diagnostic>
        <!-- 
        *
        *
        *   CONTENT MESSAGES
        *
        *
        *
        !-->
        <!-- section messages -->
        <diagnostic id="m200" xml:lang="en">
            section: name attribute is unique for the content context.
        </diagnostic>
        <!-- label messages -->
        <diagnostic id="m210" xml:lang="en">
            label: it must not be empty.    
        </diagnostic>
        <!-- close messages -->
        <diagnostic id="m220" xml:lang="en">
            close: code is unique for the question context.   
        </diagnostic>
        <!-- open messages -->
        <diagnostic id="m230" xml:lang="en">
            open: code is unique for the question context.      
        </diagnostic>
        <!-- question messages -->
        <diagnostic id="m240" xml:lang="en">
            question: name is unique for the section context.     
        </diagnostic>
        <!-- constant messages -->
        <diagnostic id="m250" xml:lang="en">
            constant: An integer value is expected.        
        </diagnostic>
        <diagnostic id="m251" xml:lang="en">
            constant: A string value is expected.    
        </diagnostic>
        <diagnostic id="m252" xml:lang="en">
            constant: A decimal value is expected.    
        </diagnostic>
        <diagnostic id="m253">
            constant: A boolean value is expected.
        </diagnostic>
        <diagnostic id="m254">
            min: The value expected must be less or equals to max value.
        </diagnostic>
        <diagnostic id="m255">
            value: The value expected must be greather than or equals to min value.
        </diagnostic>
        <diagnostic id="m256">
            value: The value expected must be less than or equals to max value.
        </diagnostic>
        <!-- Row and column messages -->
        <diagnostic id="m260" xml:lang="en">
            row: name is unique for matrix row question context.
        </diagnostic>
        <diagnostic id="m270" xml:lang="en">
            column: name is unique for matrix column question context.
        </diagnostic>
        <!-- 
        *
        *
        *   FIELD MESSAGES
        *
        *
        *
        !-->
        <diagnostic id="m400" xml:lang="en">
            <value-of select="$field/name()"/>: id attribute is unique for the field context. 
        </diagnostic>
        <!-- 
        *
        *
        *   PERSONALISATION MESSAGES
        *
        *
        *
        !-->
        <!-- piping messages -->
        <diagnostic id="m500" xml:lang="en">
            piping: id attribute must reference to a section name defined in content context.
        </diagnostic>
        <diagnostic id="m501" xml:lang="en">
            piping: id attribute is unique for the personalisation context.
        </diagnostic>
        <!-- pipe messages -->
        <diagnostic id="m510" xml:lang="en">
            pipe: id attribute must not be empty.
        </diagnostic>
        <diagnostic id="m511" xml:lang="en">
            pipe: id attribute is unique for the current piping. 
        </diagnostic>
        <diagnostic id="m512" xml:lang="en">
            pipe: ref attribute must refer to a pipe defined in the piping of the section.
        </diagnostic>
        <!-- displaying messages -->
        <diagnostic id="m600" xml:lang="en">
            displaying: id attribute must reference to a section name defined in content context.
        </diagnostic>
        <diagnostic id="m601" xml:lang="en">
            displaying: id attribute is unique for the personalisation context.
        </diagnostic>
        <!-- display messages -->
        <diagnostic id="m610" xml:lang="en">
            display: id attribute must not be empty.
        </diagnostic>
        <diagnostic id="m611" xml:lang="en">
            display: id attribute is unique for the current displaying. 
        </diagnostic>
        <diagnostic id="m612" xml:lang="en">
            display: ref attribute must refer to a display defined in the displaying of the section.
        </diagnostic>
        <!-- randomising messages -->
        <diagnostic id="m700" xml:lang="en">
            subset/code: ref attribute must be unique in the subset.
        </diagnostic>
        <diagnostic id="m701" xml:lang="en">
            subset/code: ref must reference to a response code of the question.
        </diagnostic>
    </diagnostics>
</schema>
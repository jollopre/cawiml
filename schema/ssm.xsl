<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:ssm="http://www.surveysm.com"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                              title="Schematron rules for Survey State Model (SSM)"
                              schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:ns-prefix-in-attribute-values uri="http://www.surveysm.com" prefix="ssm"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">statemodel</xsl:attribute>
            <xsl:attribute name="name">statemodel</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M2"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">source</xsl:attribute>
            <xsl:attribute name="name">source</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M3"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">state</xsl:attribute>
            <xsl:attribute name="name">state</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M4"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">transition</xsl:attribute>
            <xsl:attribute name="name">transition</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M5"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">include</xsl:attribute>
            <xsl:attribute name="name">include</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M6"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">for</xsl:attribute>
            <xsl:attribute name="name">for</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">composite</xsl:attribute>
            <xsl:attribute name="name">composite</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M8"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">variable</xsl:attribute>
            <xsl:attribute name="name">variable</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M9"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">multivariable</xsl:attribute>
            <xsl:attribute name="name">multivariable</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M10"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">computation</xsl:attribute>
            <xsl:attribute name="name">computation</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M11"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">parameter</xsl:attribute>
            <xsl:attribute name="name">parameter</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M12"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">piping</xsl:attribute>
            <xsl:attribute name="name">piping</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M13"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">pipe</xsl:attribute>
            <xsl:attribute name="name">pipe</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M14"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">displaying</xsl:attribute>
            <xsl:attribute name="name">displaying</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M15"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">display</xsl:attribute>
            <xsl:attribute name="name">display</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M16"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">subset_code</xsl:attribute>
            <xsl:attribute name="name">subset_code</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M17"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">section</xsl:attribute>
            <xsl:attribute name="name">section</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M18"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">label</xsl:attribute>
            <xsl:attribute name="name">label</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M19"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">close</xsl:attribute>
            <xsl:attribute name="name">close</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M20"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">open</xsl:attribute>
            <xsl:attribute name="name">open</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M21"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">question</xsl:attribute>
            <xsl:attribute name="name">question</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M22"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">row</xsl:attribute>
            <xsl:attribute name="name">row</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M23"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">column</xsl:attribute>
            <xsl:attribute name="name">column</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M24"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">constant</xsl:attribute>
            <xsl:attribute name="name">constant</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M25"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">min</xsl:attribute>
            <xsl:attribute name="name">min</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M26"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">value</xsl:attribute>
            <xsl:attribute name="name">value</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M27"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">field</xsl:attribute>
            <xsl:attribute name="name">field</xsl:attribute>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M28"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->
<svrl:text xmlns:svrl="http://purl.oclc.org/dsdl/svrl">Schematron rules for Survey State Model (SSM)</svrl:text>

   <!--PATTERN statemodel-->


	<!--RULE -->
<xsl:template match="ssm:statemodel" priority="1000" mode="M2">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:statemodel"/>
      <xsl:variable name="statemodel" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(//ssm:section[@id = $statemodel/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//ssm:section[@id = $statemodel/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m00">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            statemodel: ref attribute must reference to a section defined in content context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::*[@ref = $statemodel/@ref]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::*[@ref = $statemodel/@ref]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m01">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            statemodel: ref attribute is unique for the routing context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M2"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M2"/>
   <xsl:template match="@*|node()" priority="-2" mode="M2">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M2"/>
   </xsl:template>

   <!--PATTERN source-->


	<!--RULE -->
<xsl:template match="ssm:source" priority="1000" mode="M3">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:source"/>
      <xsl:variable name="source" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(following-sibling::*[@id = $source/@id])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(following-sibling::*[@id = $source/@id])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m10">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            source: id attribute must reference to a state defined in the current statemodel.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M3"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M3"/>
   <xsl:template match="@*|node()" priority="-2" mode="M3">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M3"/>
   </xsl:template>

   <!--PATTERN state-->


	<!--RULE -->
<xsl:template match="ssm:state" priority="1000" mode="M4">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:state"/>
      <xsl:variable name="state" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(./@id)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(./@id)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m20">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            state: id attribute must not be empty.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(exists(preceding-sibling::*[local-name() = 'state'][@id = $state/@id]))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(exists(preceding-sibling::*[local-name() = 'state'][@id = $state/@id]))">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m21">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            state: id attribute is unique for the current statemodel. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M4"/>
   <xsl:template match="@*|node()" priority="-2" mode="M4">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M4"/>
   </xsl:template>

   <!--PATTERN transition-->


	<!--RULE -->
<xsl:template match="ssm:transition" priority="1000" mode="M5">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:transition"/>
      <xsl:variable name="transition" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(./@target)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(./@target)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m30">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            transition: target attribute must not be empty.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:state/preceding-sibling::ssm:state[@id = $transition/@target]) or                           exists(ancestor::ssm:state/following-sibling::ssm:state[@id = $transition/@target])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:state/preceding-sibling::ssm:state[@id = $transition/@target]) or exists(ancestor::ssm:state/following-sibling::ssm:state[@id = $transition/@target])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m31">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            transition: target attribute must reference to a state defined in the current statemodel.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="not(ancestor::ssm:state/@id  = $transition/@target)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(ancestor::ssm:state/@id = $transition/@target)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m32">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            transition: target attribute must not reference to itself because it creates a loop.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M5"/>
   <xsl:template match="@*|node()" priority="-2" mode="M5">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M5"/>
   </xsl:template>

   <!--PATTERN include-->


	<!--RULE -->
<xsl:template match="ssm:include" priority="1000" mode="M6">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:include"/>
      <xsl:variable name="include" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(./@statemodel)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(./@statemodel)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m40">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            include: statemodel attribute must not be empty.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:routing/ssm:statemodel[@ref = $include/@statemodel])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:routing/ssm:statemodel[@ref = $include/@statemodel])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m41">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            include: statemodel attribute must reference to a statemodel defined in routing context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M6"/>
   <xsl:template match="@*|node()" priority="-2" mode="M6">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M6"/>
   </xsl:template>

   <!--PATTERN for-->


	<!--RULE -->
<xsl:template match="ssm:for/ssm:transition" priority="1003" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:for/ssm:transition"/>
      <xsl:variable name="transition" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:state/preceding-sibling::ssm:state[@id=$transition/@target]) or                           exists(ancestor::ssm:state/following-sibling::ssm:state[@id=$transition/@target])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:state/preceding-sibling::ssm:state[@id=$transition/@target]) or exists(ancestor::ssm:state/following-sibling::ssm:state[@id=$transition/@target])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m50">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            transition: target attribute must reference to a composite state. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="ssm:for/ssm:field" priority="1002" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:for/ssm:field"/>
      <xsl:variable name="iterator" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(./@ref)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(./@ref)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m52">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            variable: ref attribute must not be empty
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:ssm/ssm:field/ssm:iterator[@id = $iterator/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:ssm/ssm:field/ssm:iterator[@id = $iterator/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m53">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            variable: ref attribute must reference to a iterator variable defined in field context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="ssm:for/ssm:in/ssm:range/child::*/ssm:variable"
                 priority="1001"
                 mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:for/ssm:in/ssm:range/child::*/ssm:variable"/>
      <xsl:variable name="statemodel" select="ancestor::ssm:statemodel"/>
      <xsl:variable name="variable" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:open[@name = $variable/@ref]/ssm:integer) or                           exists(ancestor::ssm:ssm/ssm:field/ssm:integer[@id = $variable/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:open[@name = $variable/@ref]/ssm:integer) or exists(ancestor::ssm:ssm/ssm:field/ssm:integer[@id = $variable/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m51">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            variable: ref attribute must reference to an open integer question or an integer variable 
            defined in field context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="ssm:for/ssm:in/ssm:list" priority="1000" mode="M7">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:for/ssm:in/ssm:list"/>
      <xsl:variable name="list" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:ssm/ssm:field/ssm:list[@name = $list/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:ssm/ssm:field/ssm:list[@name = $list/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m54">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            list: ref attribute must reference to a list variable defined in field context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M7"/>
   </xsl:template>

   <!--PATTERN composite-->


	<!--RULE -->
<xsl:template match="ssm:state" priority="1000" mode="M8">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:state"/>
      <xsl:variable name="state" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(child::ssm:include) and not(exists(child::ssm:transition))) then                           exists(preceding-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]) or                           exists(following-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id])                           else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(child::ssm:include) and not(exists(child::ssm:transition))) then exists(preceding-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]) or exists(following-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]) else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>  
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m22">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            state: transition is required for composite state.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(child::ssm:include) and exists(child::ssm:transition)) then                 not(exists(preceding-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]) or                 exists(following-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]))                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(child::ssm:include) and exists(child::ssm:transition)) then not(exists(preceding-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id]) or exists(following-sibling::ssm:state/ssm:for/ssm:transition[@target = $state/@id])) else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m23">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            state: transition is forbidden because this state is target of a FOR state.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M8"/>
   <xsl:template match="@*|node()" priority="-2" mode="M8">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M8"/>
   </xsl:template>

   <!--PATTERN variable-->


	<!--RULE -->
<xsl:template match="ssm:state/ssm:variable" priority="1002" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:state/ssm:variable"/>
      <xsl:variable name="statemodel" select="ancestor::ssm:statemodel"/>
      <xsl:variable name="variable" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]))                            then true()                           else false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref])) then true() else false()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m60">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            variable: ref attribute must reference to a question defined in the section.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="ssm:state//ssm:variable" priority="1001" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:state//ssm:variable"/>
      <xsl:variable name="statemodel" select="ancestor::ssm:statemodel"/>
      <xsl:variable name="variable" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]))                  then true()                 else if(exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref]))                  then true()                  else false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref])) then true() else if(exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref])) then true() else false()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m61">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            variable: ref attribute must reference to a question or a field.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="ssm:pipe//ssm:variable" priority="1000" mode="M9">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:pipe//ssm:variable"/>
      <xsl:variable name="piping" select="ancestor::ssm:piping"/>
      <xsl:variable name="variable" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $piping/@ref]/child::*[@name = $variable/@ref]))                  then true()                 else if(exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref]))                  then true()                  else false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $piping/@ref]/child::*[@name = $variable/@ref])) then true() else if(exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref])) then true() else false()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m61">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            variable: ref attribute must reference to a question or a field.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M9"/>
   <xsl:template match="@*|node()" priority="-2" mode="M9">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M9"/>
   </xsl:template>

   <!--PATTERN multivariable-->


	<!--RULE -->
<xsl:template match="ssm:state//ssm:multivariable" priority="1000" mode="M10">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:state//ssm:multivariable"/>
      <xsl:variable name="statemodel" select="ancestor::ssm:statemodel"/>
      <xsl:variable name="multivariable" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]))                  then true()                 else false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref])) then true() else false()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m62">

            multivariable: ref attribute must reference to a grid question.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/*/ssm:rows/child::*[@code = $multivariable/@row]))                 then true()                 else false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/*/ssm:rows/child::*[@code = $multivariable/@row])) then true() else false()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m63">

            multivariable: row attribute must reference to a grid question's row.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/ssm:numeric))                 then exists($multivariable/@column)                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/ssm:numeric)) then exists($multivariable/@column) else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m64">

            multivariable: column attribute is expected for a numeric grid question
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(exists($multivariable/@column))                              then if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/ssm:numeric/ssm:columns/child::*[@code = $multivariable/@column]))                                     then true()                                     else false()                             else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(exists($multivariable/@column)) then if(exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/ssm:grid[@name = $multivariable/@ref]/ssm:numeric/ssm:columns/child::*[@code = $multivariable/@column])) then true() else false() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m65">

            multivariable: column attribute must reference to a numeric grid question's column.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M10"/>
   <xsl:template match="@*|node()" priority="-2" mode="M10">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M10"/>
   </xsl:template>

   <!--PATTERN computation-->


	<!--RULE -->
<xsl:template match="ssm:computation" priority="1000" mode="M11">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:computation"/>
      <xsl:variable name="variable" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:ssm/ssm:field/child::*[@id = $variable/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>  
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m70">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            computation: ref attribute must reference to a field. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M11"/>
   <xsl:template match="@*|node()" priority="-2" mode="M11">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M11"/>
   </xsl:template>

   <!--PATTERN parameter-->


	<!--RULE -->
<xsl:template match="ssm:parameter" priority="1001" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:parameter"/>
      <xsl:variable name="statemodel" select="ancestor::ssm:statemodel"/>
      <xsl:variable name="section" select="ancestor::ssm:section"/>
      <xsl:variable name="variable" select="preceding-sibling::*[name() eq 'variable']"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(preceding-sibling::*[name() eq 'variable'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(preceding-sibling::*[name() eq 'variable'])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m80">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            parameter: variable is expected as preceding-sibling
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref][name() eq 'matrix'])                        or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref][name() eq 'form'])                        or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref][name() eq 'matrix'])                        or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref][name() eq 'form'])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref][name() eq 'matrix']) or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref][name() eq 'form']) or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref][name() eq 'matrix']) or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref][name() eq 'form'])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m81">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            parameter: is allowed for matrix and form variables.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

	  <!--RULE -->
<xsl:template match="ssm:parameter/ssm:matrix" priority="1000" mode="M12">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ssm:parameter/ssm:matrix"/>
      <xsl:variable name="statemodel" select="ancestor::ssm:statemodel"/>
      <xsl:variable name="section" select="ancestor::ssm:section"/>
      <xsl:variable name="variable"
                    select="parent::*/preceding-sibling::*[name() eq 'variable']"/>
      <xsl:variable name="matrix" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]/*/ssm:row[@name = $matrix/@row])                        or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref]/*/ssm:row[@name = $matrix/@row])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]/*/ssm:row[@name = $matrix/@row]) or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref]/*/ssm:row[@name = $matrix/@row])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m82">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            parameter/matrix: row referenced does not exists for the variable. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]/*/ssm:column[@name = $matrix/@column])                 or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref]/*/ssm:column[@name = $matrix/@column])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $statemodel/@ref]/child::*[@name = $variable/@ref]/*/ssm:column[@name = $matrix/@column]) or exists(ancestor::ssm:ssm/ssm:content/ssm:section[@id = $section/@id]/child::*[@name = $variable/@ref]/*/ssm:column[@name = $matrix/@column])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m83">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            parameter/matrix: column referenced does not exists for the variable. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M12"/>
   <xsl:template match="@*|node()" priority="-2" mode="M12">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M12"/>
   </xsl:template>

   <!--PATTERN piping-->


	<!--RULE -->
<xsl:template match="ssm:piping" priority="1000" mode="M13">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:piping"/>
      <xsl:variable name="piping" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(//ssm:section[@id = $piping/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//ssm:section[@id = $piping/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m500">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            piping: id attribute must reference to a section name defined in content context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::ssm:piping[@ref = $piping/@ref]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::ssm:piping[@ref = $piping/@ref]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m501">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            piping: id attribute is unique for the personalisation context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M13"/>
   <xsl:template match="@*|node()" priority="-2" mode="M13">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M13"/>
   </xsl:template>

   <!--PATTERN pipe-->


	<!--RULE -->
<xsl:template match="ssm:pipe" priority="1000" mode="M14">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:pipe"/>
      <xsl:variable name="pipe" select="."/>
      <xsl:variable name="section" select="ancestor::ssm:section"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(boolean(@id)) then string-length(./@id)&gt;0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(boolean(@id)) then string-length(./@id)&gt;0 else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m510">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            pipe: id attribute must not be empty.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(boolean(@id)) then count(preceding-sibling::*[@id = $pipe/@id]) = 0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(boolean(@id)) then count(preceding-sibling::*[@id = $pipe/@id]) = 0 else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m511">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            pipe: id attribute is unique for the current piping. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(boolean(@ref)) then exists(//ssm:piping[@ref = $section/@id]/ssm:pipe[@id = $pipe/@ref]) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(boolean(@ref)) then exists(//ssm:piping[@ref = $section/@id]/ssm:pipe[@id = $pipe/@ref]) else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m512">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            pipe: ref attribute must refer to a pipe defined in the piping of the section.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M14"/>
   <xsl:template match="@*|node()" priority="-2" mode="M14">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M14"/>
   </xsl:template>

   <!--PATTERN displaying-->


	<!--RULE -->
<xsl:template match="ssm:displaying" priority="1000" mode="M15">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:displaying"/>
      <xsl:variable name="displaying" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(//ssm:section[@id = $displaying/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(//ssm:section[@id = $displaying/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m600">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            displaying: id attribute must reference to a section name defined in content context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::ssm:displaying[@ref = $displaying/@ref]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::ssm:displaying[@ref = $displaying/@ref]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m601">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            displaying: id attribute is unique for the personalisation context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M15"/>
   <xsl:template match="@*|node()" priority="-2" mode="M15">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M15"/>
   </xsl:template>

   <!--PATTERN display-->


	<!--RULE -->
<xsl:template match="ssm:display" priority="1000" mode="M16">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:display"/>
      <xsl:variable name="display" select="."/>
      <xsl:variable name="section" select="ancestor::ssm:section"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(boolean(@id)) then string-length(./@id)&gt;0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(boolean(@id)) then string-length(./@id)&gt;0 else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m610">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            display: id attribute must not be empty.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(boolean(@id)) then count(preceding-sibling::*[@id = $display/@id]) = 0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(boolean(@id)) then count(preceding-sibling::*[@id = $display/@id]) = 0 else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m611">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            display: id attribute is unique for the current displaying. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if(boolean(@ref)) then exists(//ssm:displaying[@ref = $section/@id]/ssm:display[@id = $display/@ref]) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(boolean(@ref)) then exists(//ssm:displaying[@ref = $section/@id]/ssm:display[@id = $display/@ref]) else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m612">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            display: ref attribute must refer to a display defined in the displaying of the section.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M16"/>
   <xsl:template match="@*|node()" priority="-2" mode="M16">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M16"/>
   </xsl:template>

   <!--PATTERN subset_code-->


	<!--RULE -->
<xsl:template match="ssm:subset/ssm:code" priority="1000" mode="M17">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:subset/ssm:code"/>
      <xsl:variable name="code" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::ssm:code[@ref = $code/@ref]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::ssm:code[@ref = $code/@ref]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m700">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            subset/code: ref attribute must be unique in the subset.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists(parent::*/parent::*/following-sibling::*[@code = $code/@ref])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists(parent::*/parent::*/following-sibling::*[@code = $code/@ref])">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m701">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            subset/code: ref must reference to a response code of the question.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M17"/>
   <xsl:template match="@*|node()" priority="-2" mode="M17">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M17"/>
   </xsl:template>

   <!--PATTERN section-->


	<!--RULE -->
<xsl:template match="ssm:section" priority="1000" mode="M18">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:section"/>
      <xsl:variable name="section" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::*[@id = $section/@id]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::*[@id = $section/@id]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m200">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            section: name attribute is unique for the content context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M18"/>
   <xsl:template match="@*|node()" priority="-2" mode="M18">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M18"/>
   </xsl:template>

   <!--PATTERN label-->


	<!--RULE -->
<xsl:template match="ssm:label" priority="1000" mode="M19">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:label"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="string-length(.)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="string-length(.)&gt;0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m210">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            label: it must not be empty.    
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M19"/>
   <xsl:template match="@*|node()" priority="-2" mode="M19">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M19"/>
   </xsl:template>

   <!--PATTERN close-->


	<!--RULE -->
<xsl:template match="ssm:close" priority="1000" mode="M20">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:close"/>
      <xsl:variable name="response" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::*[@code = $response/@code]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::*[@code = $response/@code]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m220">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            close: code is unique for the question context.   
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M20"/>
   <xsl:template match="@*|node()" priority="-2" mode="M20">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M20"/>
   </xsl:template>

   <!--PATTERN open-->


	<!--RULE -->
<xsl:template match="ssm:open" priority="1000" mode="M21">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:open"/>
      <xsl:variable name="response" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (not(exists(parent::ssm:section))) then                            count(preceding-sibling::*[@code = $response/@code]) = 0                           else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(exists(parent::ssm:section))) then count(preceding-sibling::*[@code = $response/@code]) = 0 else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m230">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            open: code is unique for the question context.      
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (not(exists(parent::ssm:section))) then                           count(preceding-sibling::*[local-name() = 'group']/child::*[@code = $response/@code]) = 0                           else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(exists(parent::ssm:section))) then count(preceding-sibling::*[local-name() = 'group']/child::*[@code = $response/@code]) = 0 else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m230">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            open: code is unique for the question context.      
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (exists(parent::ssm:group)) then                           count(parent::node()/preceding-sibling::*[@code = $response/@code]) = 0 and                           count(parent::node()/preceding-sibling::*[local-name() = 'group']/child::*[@code = $response/@code]) = 0                           else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (exists(parent::ssm:group)) then count(parent::node()/preceding-sibling::*[@code = $response/@code]) = 0 and count(parent::node()/preceding-sibling::*[local-name() = 'group']/child::*[@code = $response/@code]) = 0 else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M21"/>
   <xsl:template match="@*|node()" priority="-2" mode="M21">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M21"/>
   </xsl:template>

   <!--PATTERN question-->


	<!--RULE -->
<xsl:template match="ssm:section/child::*" priority="1000" mode="M22">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:section/child::*"/>
      <xsl:variable name="name" select="./@name"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::*[@name = $name]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::*[@name = $name]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m240">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            question: name is unique for the section context.     
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M22"/>
   <xsl:template match="@*|node()" priority="-2" mode="M22">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M22"/>
   </xsl:template>

   <!--PATTERN row-->


	<!--RULE -->
<xsl:template match="ssm:row" priority="1000" mode="M23">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:row"/>
      <xsl:variable name="row" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::*[@name = $row/@name]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::*[@name = $row/@name]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m260">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            row: name is unique for matrix row question context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M23"/>
   <xsl:template match="@*|node()" priority="-2" mode="M23">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M23"/>
   </xsl:template>

   <!--PATTERN column-->


	<!--RULE -->
<xsl:template match="ssm:column" priority="1000" mode="M24">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:column"/>
      <xsl:variable name="column" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::*[local-name() ne 'row'][@name = $column/@name]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::*[local-name() ne 'row'][@name = $column/@name]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m270">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            column: name is unique for matrix column question context.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M24"/>
   <xsl:template match="@*|node()" priority="-2" mode="M24">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M24"/>
   </xsl:template>

   <!--PATTERN constant-->


	<!--RULE -->
<xsl:template match="ssm:constant" priority="1000" mode="M25">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:constant"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@type eq 'integer') then                 if (@value castable as xs:integer) then true() else false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@type eq 'integer') then if (@value castable as xs:integer) then true() else false() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m250">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            constant: An integer value is expected.        
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@type eq 'string') then                 if (@value castable as xs:string) then true() else false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@type eq 'string') then if (@value castable as xs:string) then true() else false() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m251">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            constant: A string value is expected.    
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@type eq 'decimal') then                 if (@value castable as xs:decimal) then true() else false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@type eq 'decimal') then if (@value castable as xs:decimal) then true() else false() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m252">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

            constant: A decimal value is expected.    
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (@type eq 'boolean') then                 if (@value castable as xs:boolean) then true() else false()                 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (@type eq 'boolean') then if (@value castable as xs:boolean) then true() else false() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m253">

            constant: A boolean value is expected.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M25"/>
   <xsl:template match="@*|node()" priority="-2" mode="M25">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M25"/>
   </xsl:template>

   <!--PATTERN min-->


	<!--RULE -->
<xsl:template match="ssm:min" priority="1000" mode="M26">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:min"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (not(empty(./text()))) then                             if (not(empty(./following-sibling::ssm:max/text()))) then                             boolean(number(./text()) &lt;= number(./following-sibling::ssm:max/text()))                             else true()                           else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(empty(./text()))) then if (not(empty(./following-sibling::ssm:max/text()))) then boolean(number(./text()) &lt;= number(./following-sibling::ssm:max/text())) else true() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m254">

            min: The value expected must be less or equals to max value.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M26"/>
   <xsl:template match="@*|node()" priority="-2" mode="M26">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M26"/>
   </xsl:template>

   <!--PATTERN value-->


	<!--RULE -->
<xsl:template match="ssm:value" priority="1000" mode="M27">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:value"/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (not(empty(./preceding-sibling::ssm:min/text()))) then                                  if (not(empty(./text()))) then boolean(number(./text()) &gt;= number(./preceding-sibling::ssm:min/text())) else true()                           else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(empty(./preceding-sibling::ssm:min/text()))) then if (not(empty(./text()))) then boolean(number(./text()) &gt;= number(./preceding-sibling::ssm:min/text())) else true() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m255">

            value: The value expected must be greather than or equals to min value.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="if (not(empty(./preceding-sibling::ssm:max/text()))) then                           if (not(empty(./text()))) then boolean(number(./text()) &lt;= number(./preceding-sibling::ssm:max/text())) else true()                           else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(empty(./preceding-sibling::ssm:max/text()))) then if (not(empty(./text()))) then boolean(number(./text()) &lt;= number(./preceding-sibling::ssm:max/text())) else true() else true()">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            </svrl:text> 
               <svrl:diagnostic-reference diagnostic="m256">

            value: The value expected must be less than or equals to max value.
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M27"/>
   <xsl:template match="@*|node()" priority="-2" mode="M27">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M27"/>
   </xsl:template>

   <!--PATTERN field-->


	<!--RULE -->
<xsl:template match="ssm:field/child::*" priority="1000" mode="M28">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl" context="ssm:field/child::*"/>
      <xsl:variable name="field" select="."/>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="count(preceding-sibling::*[@id = $field/@id]) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(preceding-sibling::*[@id = $field/@id]) = 0">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text/> 
               <svrl:diagnostic-reference diagnostic="m400">
                  <xsl:attribute name="xml:lang">en</xsl:attribute>

                  <xsl:text/>
                  <xsl:value-of select="$field/name()"/>
                  <xsl:text/>: id attribute is unique for the field context. 
        </svrl:diagnostic-reference>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M28"/>
   <xsl:template match="@*|node()" priority="-2" mode="M28">
      <xsl:apply-templates select="*|comment()|processing-instruction()" mode="M28"/>
   </xsl:template>
</xsl:stylesheet>

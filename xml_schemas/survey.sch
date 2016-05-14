<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    <pattern id="integrity_constraint" >
        <rule context="/survey/section">
            <let name="id" value="@id"/>
            <assert test="count(preceding-sibling::*[@id = $id]) = 0">
               duplicate key found for section id <value-of select="$id"/>
            </assert>
        </rule>
    </pattern>
</schema>
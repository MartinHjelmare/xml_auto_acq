<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output indent="yes"/>
	<!-- Well and Field params -->
	<xsl:param name="WELLX"/>
	<xsl:param name="WELLY"/>
	<xsl:param name="FIELDX" select="'0'"/>
	<xsl:param name="FIELDY" select="'0'"/>
	<!-- Attributes to change -->
	<xsl:param name="ENABLE" select="'0'"/>
	<xsl:param name="JOBID" select="'0'"/>
	<xsl:param name="JOBNAME" select="'0'"/>
	<xsl:param name="DRIFT" select="'0'"/>
	<xsl:param name="DX" select="'0'"/>
	<xsl:param name="DY" select="'0'"/>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="ScanFieldArray/ScanFieldData/@Enabled">
		<xsl:choose>
			<xsl:when test="../@WellX=$WELLX and ../@WellY=$WELLY and ($FIELDX='0' or ../@FieldX=$FIELDX) and ($FIELDY='0' or ../@FieldY=$FIELDY)">
				<!-- Enabled -->
				<xsl:attribute name="Enabled">
					<xsl:choose>
						<xsl:when test="not($ENABLE='0')">
								<xsl:value-of select="$ENABLE"/>
						</xsl:when>
						<xsl:otherwise>
								<xsl:value-of select="$ENABLE"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<!-- JobId -->
				<xsl:attribute name="JobId">
					<xsl:choose>
						<xsl:when test="not($JOBID='0')">
								<xsl:value-of select="$JOBID"/>
						</xsl:when>
						<xsl:otherwise>
								<xsl:value-of select="../@JobId"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<!-- JobName -->
				<xsl:attribute name="JobName">
					<xsl:choose>
						<xsl:when test="not($JOBNAME='0')">
								<xsl:value-of select="$JOBNAME"/>
						</xsl:when>
						<xsl:otherwise>
								<xsl:value-of select="../@JobName"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<!-- IsDriftCompensationField -->
				<xsl:attribute name="IsDriftCompensationField">
					<xsl:choose>
						<xsl:when test="not($DRIFT='0')">
								<xsl:value-of select="$DRIFT"/>
						</xsl:when>
						<xsl:otherwise>
								<xsl:value-of select="../@IsDriftCompensationField"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="Enabled">
					<xsl:value-of select="../@Enabled"/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ScanFieldArray/ScanFieldData/FieldXCoordinate">
	    <xsl:choose>
			<xsl:when test="../@WellX=$WELLX and ../@WellY=$WELLY and ($FIELDX='0' or ../@FieldX=$FIELDX) and ($FIELDY='0' or ../@FieldY=$FIELDY)">
	            <!-- FieldXCoordinate -->
				<xsl:element name="FieldXCoordinate">
					<xsl:choose>
						<xsl:when test="not($DX='0')">
							<xsl:value-of select="../FieldXCoordinate+$DX"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="../FieldXCoordinate"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="FieldXCoordinate">
					<xsl:value-of select="../FieldXCoordinate"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="ScanFieldArray/ScanFieldData/FieldYCoordinate">
	    <xsl:choose>
			<xsl:when test="../@WellX=$WELLX and ../@WellY=$WELLY and ($FIELDX='0' or ../@FieldX=$FIELDX) and ($FIELDY='0' or ../@FieldY=$FIELDY)">
	            <!-- FieldYCoordinate -->
				<xsl:element name="FieldYCoordinate">
					<xsl:choose>
						<xsl:when test="not($DY='0')">
						    <xsl:value-of select="../FieldYCoordinate+$DY"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="../FieldYCoordinate"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="FieldYCoordinate">
					<xsl:value-of select="../FieldYCoordinate"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

<!--
<xsl:template match="ScanFieldArray/ScanFieldData">
			<xsl:copy-of select="."/>
			<xsl:attribute name="Enabled">
	<xsl:choose>
		<xsl:when test="@WellX=$WELLX">
			<xsl:value-of select="$ENABLED"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
			</xsl:attribute>
</xsl:template>
-->

<!--
<xsl:template match="ScanFieldArray/ScanFieldData[@WellX='$WELLX'][@WellY='$WELLY']">
	<xsl:attribute name="Enabled">
		<xsl:value-of select="$ENABLED"/>
	</xsl:attribute>
</xsl:template>
-->

<!--
<xsl:template match="ScanFieldArray">
	<xsl:for-each select="ScanFieldData[@WellX=$WELLX][@WellY=$WELLY]">
		<xsl:copy>
			<xsl:attribute name="Enabled">false</xsl:attribute>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>
-->


</xsl:stylesheet>

<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:new="https://www.newater.com.au/" version="3.1">
  <xsl:output method="xml" indent="yes" encoding="UTF-8" />
  <!-- This is the xslt for Invoices, it currently provides for both Quarterly and Sundry bills -->
  <!-- It was developed this way because there are many -->
  <!-- The intention was to split out the code towards the end of the project -->
  <!-- declaration of all the formats -->
  <xsl:variable name="totalFormat" select="'$###,##0.00'" />
  <xsl:variable name="creditFormat" select="'-$###,##0.00'" />
  <xsl:variable name="twoDecimalsFormat" select="'###,##0.00'" />
  <xsl:variable name="twoDecimalsNoCommasFormat" select="'#0.00'" />
  <xsl:variable name="noDecimalsFormat" select="'0'" />
  <xsl:variable name="noDecimalsLDayFormat" select="'0 L/day'" />
  <xsl:variable name="dateFormat" select="'[D] [MNn,3-3] [Y0001]'" />
  <xsl:variable name="dateFormatBreakdown" select="'[D01]/[M01]/[Y0001]'" />
  <!-- a convenience function to help with development that will write out strings to the console -->
  <xsl:function name="new:log">
    <xsl:param name="message" />
    <xsl:message>
      <xsl:value-of select="$message" />
    </xsl:message>
  </xsl:function>
  <!-- functions -->
  <xsl:function name="new:rateAsString">
    <!-- returns the rate in format via string manipulation -->
    <xsl:param name="rate" />
    <xsl:param name="precision" />
    <xsl:variable name="result" select="concat(substring-before(xs:string($rate), '.'), '.', substring(substring-after(xs:string($rate), '.'), 1, $precision))" />
    <xsl:value-of select="$result" />
  </xsl:function>
  <xsl:function name="new:selectWaterRate">
    <!-- returns the agreedRate or rateRetailAmount if the agreedRate is empty -->
    <xsl:param name="agreedRate" />
    <xsl:param name="rateRetailAmount" />
    <xsl:choose>
      <xsl:when test="not($agreedRate = '')">
        <xsl:value-of select="new:rateAsString($agreedRate, 2)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="new:rateAsString($rateRetailAmount, 2)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="new:rateDividedByYear">
    <!-- returns the rate divided by year -->
    <xsl:param name="isLeapYear" />
    <xsl:param name="agreedRate" />
    <xsl:param name="rateRetailAmount" />
    <xsl:variable name="leapYearDays" select="366.00" />
    <xsl:variable name="normalYearDays" select="365.00" />
    <xsl:variable name="precision" select="2" />
    <xsl:choose>
      <xsl:when test="not($agreedRate = '')">
        <xsl:if test="$isLeapYear = 'false'">
          <xsl:value-of select="new:rateAsString(($agreedRate * 100 div $normalYearDays), $precision)" />
        </xsl:if>
        <xsl:if test="$isLeapYear = 'true'">
          <xsl:value-of select="new:rateAsString(($agreedRate * 100 div $leapYearDays), $precision)" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not($rateRetailAmount = '')">
          <xsl:if test="$isLeapYear = 'false'">
            <xsl:value-of select="new:rateAsString(($rateRetailAmount * 100 div $normalYearDays), $precision)" />
          </xsl:if>
          <xsl:if test="$isLeapYear = 'true'">
            <xsl:value-of select="new:rateAsString(($rateRetailAmount * 100 div $leapYearDays), $precision)" />
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="new:timeStampToDate">
    <!-- converts timestamp data into a date by stripping of the time component of the timestamp -->
    <xsl:param name="date" />
    <xsl:if test="contains($date, '+')">
      <xsl:value-of select="xs:date(substring-before(normalize-space($date), '+'))" />
    </xsl:if>
    <xsl:if test="not(contains($date, '+'))">
      <xsl:value-of select="xs:date(normalize-space($date))" />
    </xsl:if>
  </xsl:function>
  <xsl:function name="new:dateFormat">
    <!-- converts the string value to a date format and checks for empty or missing values -->
    <xsl:param name="date" />
    <xsl:choose>
      <xsl:when test="not($date='')">
        <xsl:value-of select="format-date(new:timeStampToDate($date),$dateFormat)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="new:breakdownDate">
    <!-- converts the string value to a date format and checks for empty or missing values -->
    <xsl:param name="date" />
    <xsl:choose>
      <xsl:when test="not($date='')">
        <xsl:value-of select="format-date(new:timeStampToDate($date),$dateFormatBreakdown)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="new:truncate">
    <!-- provides truncation of input value and appends an ellipsis to the end -->
    <xsl:param name="input" />
    <xsl:param name="maxlength" />
    <xsl:choose>
      <xsl:when test="string-length($input) >= $maxlength">
        <xsl:value-of select="concat(substring($input, 1, $maxlength), '&#8230;')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$input" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:function name="new:decode">
    <!-- replaces '+' with a space -->
    <xsl:param name="string" />
    <xsl:value-of select="translate(normalize-space($string), '+', ' ')" />
  </xsl:function>
  <xsl:function name="new:stripSpaces">
    <!-- strips spaces from string values -->
    <xsl:param name="string" />
    <xsl:value-of select="translate($string, ' ', '')" />
  </xsl:function>
  <xsl:function name="new:minusZeroCheck">
    <!-- removes minis symbol from zero values -->
    <xsl:param name="value" />
    <xsl:choose>
      <xsl:when test="$value=0">
        <xsl:value-of select="format-number(0,$totalFormat)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="format-number($value,$totalFormat)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <!-- main bill template -->
  <xsl:template match="Bill">
    <xsl:variable name="node" select="." />
    <pdfDatas>
      <xsl:call-template name="pdfData">
        <xsl:with-param name="nodeParam" select="$node" />
        <xsl:with-param name="CustomerName">
          <!-- Bill Print Name logic -->
          <xsl:variable name="billPrintName1" select="new:truncate(./Contract_Bill_Print1_Reference, 40)" />
          <xsl:variable name="billPrintName2" select="new:truncate(./Contract_Bill_Print2_Reference, 40)" />
          <xsl:choose>
            <xsl:when test="($billPrintName1 != '') and ($billPrintName2 != '')">
              <!-- returns BillPrintName1 and BillPrintName if they both exist -->
              <xsl:value-of select="concat($billPrintName1,'&lt;br/&gt;',$billPrintName2)" />
            </xsl:when>
            <xsl:when test="$billPrintName1 != ''">
              <!-- returns BillPrintName1 if it exists and BillPrintName does not exist -->
              <xsl:value-of select="$billPrintName1" />
            </xsl:when>
            <!-- otherwise return the AccountName -->
            <xsl:otherwise>
              <xsl:value-of select="new:truncate(./Account_Name, 40)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <!-- this section was written by someone else and thats why we have a different naming convention used -->
        <xsl:with-param name="address_param_line1" select="./Contract_BillingStreet" />
        <xsl:with-param name="address_param_line2" select="concat(./Contract_BillingCity,' ',./Contract_BillingState,' ',./Contract_BillingPostalCode)" />
        <xsl:with-param name="invoice_type_name_param" select="'TAX INVOICE'" />
        <xsl:with-param name="accountId_param" select="./Account_Id" />
        <xsl:with-param name="account_email_param" select="./Account_Email" />
        <xsl:with-param name="billing_email_opt_in_param" select="./Account_BillingEmailOptIn" />
        <xsl:with-param name="billing_email_opt_out_link_param" select="./BillingEmailOptOutLink" />
        <xsl:with-param name="duplicate_print">
          <xsl:for-each select="./AccountLocationOccupant">
            <xsl:if test="./DuplicateInvoice='true'">
              <duplicatePrint>
                <accountId>
                  <xsl:value-of select="./LocOcc_AccountId" />
                </accountId>
              </duplicatePrint>
            </xsl:if>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
      <!-- this information here is tenant information in a landlord/tenant situation -->
      <xsl:for-each select="./AccountLocationOccupant">
        <xsl:if test="./DuplicateInvoice='true'">
          <xsl:call-template name="pdfData">
            <xsl:with-param name="nodeParam" select="$node" />
            <xsl:with-param name="CustomerName" select="./LocOcc_AccountName" />
            <xsl:with-param name="address_param_line1" select="./LocOcc_AccountStreet" />
            <xsl:with-param name="address_param_line2" select="concat(./LocOcc_AccountCity,' ',./LocOcc_AccountState,' ',./LocOcc_BillingPostalCode)" />
            <xsl:with-param name="invoice_type_name_param" select="'&lt;span&gt;TAX INVOICE - DUPLICATE&lt;/span&gt;'" />
            <xsl:with-param name="accountId_param" select="./LocOcc_AccountId" />
            <xsl:with-param name="account_email_param" select="./LocOcc_AccountEmail" />
            <xsl:with-param name="billing_email_opt_in_param" select="./LocOcc_AccountBillingEmailOptIn" />
            <xsl:with-param name="billing_email_opt_out_link_param" select="./LocOcc_BillingEmailOptOutLink" />
            <xsl:with-param name="duplicate_print">
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </pdfDatas>
  </xsl:template>
  <xsl:template name="pdfData">
    <xsl:param name="nodeParam" />
    <xsl:param name="address_param_line1" />
    <xsl:param name="address_param_line2" />
    <xsl:param name="CustomerName" />
    <xsl:param name="invoice_type_name_param" />
    <xsl:param name="accountId_param" />
    <!-- Email params -->
    <xsl:param name="duplicate_print" />
    <xsl:param name="account_email_param" />
    <xsl:param name="billing_email_opt_in_param" />
    <xsl:param name="billing_email_opt_out_link_param" />
    <!-- Global Variables -->
    <!-- fetch all the bill items that have a PDF charge type -->
    <xsl:variable name="billItems" select="$nodeParam/BillItem[ServiceItem_ServiceItemType_PDFChargeType!='']" />
    <!-- PDF Charge Types -->
    <!-- collect the bill items by thier PDF charge type -->
    <xsl:variable name="serviceBillItems" select="$billItems[ServiceItem_ServiceItemType_PDFChargeType = 'Service+Charge']" />
    <xsl:variable name="volumeBillItems" select="$billItems[ServiceItem_ServiceItemType_PDFChargeType = 'Volume+Charge']" />
    <xsl:variable name="miscellaneousBillItems" select="$billItems[ServiceItem_ServiceItemType_PDFChargeType = 'Miscellaneous']" />
    <xsl:variable name="billTransfers" select="$nodeParam/BillTransfer" />
    <xsl:variable name="totalBilledAmount" select="sum($billItems/BilledAmount[number(.) = number(.)])" />
    <xsl:variable name="totalTax" select="sum($billItems/TotalTaxAmount[number(.) = number(.)])" />
    <!-- Payments -->
    <!-- fetch all the payments ommiting goodwill payments -->
    <xsl:variable name="payments" select="$nodeParam/Payment[@RecordType = 'Payment' and not(./Payment_GoodwillPayment = 'true')]/Amount[number(.) = number(.)]" />
    <!-- payment amount is in positive amounts but must be displayed and calculated as negative amounts -->
    <xsl:variable name="totalPayments" select="sum($payments/Amount[number(.) = number(.)]) * (-1)" />
    <!-- fetch all the goodwill payments as they must be displayed and calculated separately -->
    <xsl:variable name="goodwillPayments" select="$nodeParam/Payment[@RecordType = 'Payment' and not(./Payment_GoodwillPayment = 'false')]" />
    <xsl:variable name="totalGoodwill" select="sum($goodwillPayments/Amount[number(.) = number(.)]) * (-1)" />
    <!-- fetch all the refunds as they must be displayed separately -->
    <xsl:variable name="refundPayments" select="$nodeParam/Payment[@RecordType = 'Refund']" />
    <xsl:variable name="totalRefund" select="sum($refundPayments/Amount[number(.) = number(.)]) * (-1)" />
    <xsl:variable name="returnTransferPayments" select="$nodeParam/Payment[@RecordType = 'Return%2FTransfer']" />
    <xsl:variable name="totalReturnTransfer" select="sum($returnTransferPayments/Amount[number(.) = number(.)]) * (-1)" />
    <!-- create a variable for handing any other payments -->
    <xsl:variable name="totalOtherPayments" select="$totalGoodwill + $totalRefund + $totalReturnTransfer" />
    <!-- Totals -->
    <xsl:variable name="balanceSnapshot" select="number($nodeParam/Contract_BalanceSnapshot)" />
    <xsl:variable name="contractBalance" select="number(./Contract_ContractBalance)" />
    <!-- fetch some date data for display and calculation -->
    <xsl:variable name="dateOfIssue" select="format-date(xs:date(substring-before(normalize-space($nodeParam/BillDate), '+')),$dateFormat)" />
    <xsl:variable name="nextScheduledReadingBaseDate" select="xs:date(substring-before(normalize-space($nodeParam/EndDate), '+'))" />
    <xsl:variable name="totalPaymentsReceivedToBaseDate" select="xs:date(substring-before(normalize-space($nodeParam/BillDate), '+'))" />
    <xsl:variable name="dueDateVarToAdd" select="xs:date(substring-before(normalize-space($nodeParam/BillDate), '+'))" />
    <xsl:variable name="totalPaymentsReceivedToCalculated" select="($totalPaymentsReceivedToBaseDate)-xs:dayTimeDuration('P1D')" />
    <xsl:variable name="waterComsumptionBillItemsTotalKL" select="sum($serviceBillItems/VolumeUsed[number(.) = number(.)])" />
    <xsl:variable name="waterConsumptionBillItemsTotalL" select="($waterComsumptionBillItemsTotalKL * 1000)" />
    <xsl:variable name="billStartDateAsValue" select="format-date(xs:date(substring-before(normalize-space($nodeParam/StartDate), '+')),$dateFormatBreakdown)" />
    <xsl:variable name="billEndDateAsValue" select="format-date(xs:date(substring-before(normalize-space($nodeParam/EndDate), '+')),$dateFormatBreakdown)" />
    <xsl:variable name="billStartDate" select="xs:date(substring-before(normalize-space($nodeParam/StartDate), '+'))" />
    <xsl:variable name="billEndDate" select="xs:date(substring-before(normalize-space($nodeParam/EndDate), '+'))" />
    <!-- the bill is due for payment 28 days after the bill date, this was left over from Coliban and could probably be better calculated by add 1 month rather than 4 weeks -->
    <xsl:variable name="payByDate" select="($dueDateVarToAdd)+xs:dayTimeDuration('P28D')" />
    <pdfData>
      <pdfTemplateName>
        <xsl:value-of select="$nodeParam/PdfTemplateName" />
      </pdfTemplateName>
      <contractActiveDepot>
        <xsl:value-of select="translate($nodeParam/Contract_ActiveDepot,'+',' ')" />
      </contractActiveDepot>
      <xsltTemplateName>
        <xsl:value-of select="$nodeParam/XsltName" />
      </xsltTemplateName>
      <accountId>
        <xsl:value-of select="$accountId_param" />
      </accountId>
      <printXmlBucketName>
        <xsl:value-of select="$nodeParam/PrintXmlBucketName" />
      </printXmlBucketName>
      <BillExcludeFromBatchPrint>
        <xsl:value-of select="$nodeParam/Bill_ExcludeFromBatchPrint" />
      </BillExcludeFromBatchPrint>
      <xsl:copy-of select="$duplicate_print" />
      <!-- address of where the service is being used -->
      <xsl:variable name="addressLocation" select="($nodeParam/BillItem/Location)[last()]" />
      <xsl:variable name="serviceLocation" select="$nodeParam/Contract_ActiveDepot" />
      <objectRecord>
        <objectApiName>Bill</objectApiName>
        <!-- address variables -->
        <xsl:call-template name="fieldsTemplate" />
        <field>
          <apiName>AddressLine1</apiName>
          <value>
            <xsl:value-of select="$address_param_line1" />
          </value>
        </field>
        <field>
          <apiName>AddressLine2</apiName>
          <value>
            <xsl:value-of select="$address_param_line2" />
          </value>
        </field>
        <!-- type of invoice -->
        <field>
          <apiName>Invoice_Type</apiName>
          <value>
            <xsl:value-of select="$invoice_type_name_param" />
          </value>
        </field>
        <field>
          <apiName>ServiceAddress</apiName>
          <value>
            <xsl:value-of select="concat($addressLocation/Street, ' ',$addressLocation/City, ' ',$addressLocation/State)" />
          </value>
        </field>
        <!-- start and end date of the billing period -->
        <field>
          <apiName>BillStartDate</apiName>
          <value>
            <xsl:value-of select="$billStartDateAsValue" />
          </value>
        </field>
        <field>
          <apiName>BillEndDate</apiName>
          <value>
            <xsl:value-of select="$billEndDateAsValue" />
          </value>
        </field>
        <!-- type of location being billed -->
        <xsl:variable name="locationTypeAsArray" select="$nodeParam/BillItem/Location/LocationType" />
        <field>
          <apiName>LocationType</apiName>
          <value>
            <xsl:value-of select="$locationTypeAsArray[last()]" />
          </value>
        </field>
        <!-- logic for deciding if there is a non-potable logo on the bill -->
        <!-- the message needs to come before the image, otherwise the image will not render, I don'y know why -->
        <xsl:if test="$billItems[contains(./Location/TitleDeedInfo,'Non+Potable')] or $billItems[contains(./Location/TitleDeedInfo,'Rural+Raw')]">
          <field>
            <apiName>NonPotableMessage</apiName>
            <value>Untreated water supply.&lt;br /&gt;Not suitable for human&lt;br /&gt;consumption.</value>
          </field>
          <field>
            <apiName>NonPotableImage</apiName>
            <value>&lt;img src='resources/nonpotable.png'/&gt;</value>
          </field>
        </xsl:if>
        <!-- declare some variables for the discounts -->
        <xsl:variable name="concessionDiscount" select="$nodeParam/BillItem/BillItemDiscount[./Discount/Concession]" />
        <xsl:variable name="totalDiscountAmount" select="sum($concessionDiscount/BillItemDiscountAmount[number(.)=number(.)])" />
        <!-- create a boolean for determining if to show other payments or not -->
        <xsl:variable name="showOtherPayments" select="$goodwillPayments!='' or $refundPayments!='' or $returnTransferPayments!=''" />
        <!-- we need to list Volume Charges, Service Charges and Miscellaneous Charges on the front page -->
        <objectRecordList>
          <objectApiName>CurrentCharges</objectApiName>
          <xsl:for-each select="distinct-values($billItems/ServiceItem_ServiceItemType_PDFChargeType)">
            <xsl:sort select="." data-type="text" order="descending" />
            <xsl:variable name="chargeType" select="new:stripSpaces(new:decode(.))" />
            <xsl:variable name="currentCharge" select="." />
            <xsl:variable name="chargeAmount" select="sum($billItems[ServiceItem_ServiceItemType_PDFChargeType = $currentCharge]/BilledAmount[number(.)=number(.)])" />
            <objectRecord>
              <objectApiName>
                <xsl:value-of select="$chargeType" />
              </objectApiName>
              <!-- create a label for each charge type -->
              <field>
                <apiName>ChargeType</apiName>
                <xsl:choose>
                  <xsl:when test="$chargeType='ServiceCharge'">
                    <value>
                      <xsl:value-of select="'Service charges'" />
                    </value>
                  </xsl:when>
                  <xsl:when test="$chargeType='VolumeCharge'">
                    <value>
                      <xsl:value-of select="'Volume charges'" />
                    </value>
                  </xsl:when>
                  <xsl:when test="$chargeType='Miscellaneous'">
                    <value>
                      <xsl:value-of select="'Miscellaneous'" />
                    </value>
                  </xsl:when>
                  <xsl:otherwise>
                    <value />
                  </xsl:otherwise>
                </xsl:choose>
              </field>
              <field>
                <apiName>ChargeAmount</apiName>
                <xsl:choose>
                  <!-- anything that is not a volume charge, service charge or concession needs to be totaled under Miscellaneous -->
                  <xsl:when test="$chargeType='Miscellaneous' and $showOtherPayments">
                    <value>
                      <xsl:value-of select="format-number($chargeAmount + $totalOtherPayments ,$totalFormat)" />
                    </value>
                  </xsl:when>
                  <xsl:otherwise>
                    <value>
                      <xsl:value-of select="format-number($chargeAmount ,$totalFormat)" />
                    </value>
                  </xsl:otherwise>
                </xsl:choose>
              </field>
            </objectRecord>
          </xsl:for-each>
          <!-- Show Other payments under Miscellaneous when any other payments are not empty -->
          <!-- Other payments to show under Miscellaneous when no Miscellaneous Charge Types exist -->
          <!-- in the event that no Miscellaneous Charges exist, but we have other payments to show, we need to create a heading and show them here -->
          <xsl:if test="$showOtherPayments and not($miscellaneousBillItems!='')">
            <!-- <xsl:if test="$showOtherPayments"> -->
            <objectRecord>
              <objectApiName>TotalOtherPayments</objectApiName>
              <field>
                <apiName>ChargeType</apiName>
                <value>Miscellaneous</value>
              </field>
              <field>
                <apiName>ChargeAmount</apiName>
                <value>
                  <xsl:value-of select="format-number($totalOtherPayments ,$totalFormat)" />
                </value>
              </field>
            </objectRecord>
          </xsl:if>
          <!-- Concession Charges need to be shown separately -->
          <xsl:if test="$totalDiscountAmount>0">
            <objectRecord>
              <objectApiName>ConcessionEntitlements</objectApiName>
              <field>
                <apiName>ChargeType</apiName>
                <value>Concession entitlement</value>
              </field>
              <field>
                <apiName>ChargeAmount</apiName>
                <value>
                  <xsl:value-of select="format-number($totalDiscountAmount, $creditFormat)" />
                </value>
              </field>
            </objectRecord>
          </xsl:if>
        </objectRecordList>
        <!-- Page 2 quarterly begins here -->
        <!-- gather some data to show the meter readings -->
        <xsl:if test="$volumeBillItems!=''">
          <objectRecordList>
            <objectApiName>VolumeDevices</objectApiName>
            <xsl:for-each-group group-by="concat(Reading_DeviceReference_SerialNo,Reading_ReadingDate)" select="$volumeBillItems">
              <xsl:variable name="currentCharge" select="." />
              <xsl:variable name="chargeType" select="new:stripSpaces(new:decode($currentCharge))" />
              <objectRecord>
                <objectApiName>VolumeDevice</objectApiName>
                <field>
                  <apiName>Heading</apiName>
                  <value>Devices Heading</value>
                </field>
                <objectRecord>
                  <objectRecordList>
                    <xsl:for-each select="$currentCharge">
                      <xsl:if test="not(./Device='')">
                        <xsl:variable name="startReadingID" select="./StartReadingID" />
                        <xsl:variable name="endReadingID" select="./EndReadingID" />
                        <xsl:for-each select="./Device">
                          <objectApiName>Devices</objectApiName>
                          <xsl:variable name="deviceReading" select="./Reading" />
                          <xsl:variable name="previousReading" select="$deviceReading[./ReadingId = $startReadingID]" />
                          <xsl:variable name="currentReading" select="$deviceReading[./ReadingId = $endReadingID]" />
                          <xsl:variable name="previousEstimated">
                            <xsl:if test="contains($previousReading/ReadingMethod, 'Estimated') or contains(previousReading/ReadingMethod, 'Top+Up')">
                              <xsl:value-of select="'E'" />
                            </xsl:if>
                          </xsl:variable>
                          <xsl:variable name="currentEstimated">
                            <xsl:if test="contains($currentReading/ReadingMethod, 'Estimated') or contains(currentReading/ReadingMethod, 'Top+Up')">
                              <xsl:value-of select="'E'" />
                            </xsl:if>
                          </xsl:variable>
                          <objectRecord>
                            <objectApiName>Device</objectApiName>
                            <field>
                              <apiName>MeterNumber</apiName>
                              <value>
                                <xsl:value-of select="./SerialNumber" />
                              </value>
                            </field>
                            <field>
                              <apiName>PreviousReading</apiName>
                              <value>
                                <xsl:value-of select="concat(new:breakdownDate($previousReading/ReadingDate), '&#160;&#160;', $previousReading/Reading), $previousEstimated" />
                              </value>
                            </field>
                            <field>
                              <apiName>CurrentReading</apiName>
                              <value>
                                <xsl:value-of select="concat(new:breakdownDate($currentReading/ReadingDate), '&#160;&#160;', $currentReading/Reading), $currentEstimated" />
                              </value>
                            </field>
                            <field>
                              <apiName>Usage</apiName>
                              <value>
                                <xsl:if test="not($currentReading/Reading='') and not($previousReading/Reading='')">
                                  <xsl:value-of select="format-number($currentReading/Reading - $previousReading/Reading, $noDecimalsFormat)" />
                                </xsl:if>
                              </value>
                            </field>
                          </objectRecord>
                        </xsl:for-each>
                      </xsl:if>
                    </xsl:for-each>
                  </objectRecordList>
                </objectRecord>
              </objectRecord>
            </xsl:for-each-group>
          </objectRecordList>
        </xsl:if>
        <!-- conditionally display a key on the bill to what the 'E' is for on a reading -->
        <xsl:variable name="estimatedReading" select="$volumeBillItems/Device/Reading/ReadingMethod[contains(., 'Estimated') or contains(., 'Top+Up')]" />
        <xsl:for-each select="$estimatedReading">
          <xsl:if test="position() = 1">
            <field>
              <apiName>EstimatedMessage</apiName>
              <value>E = Reading Estimated</value>
            </field>
          </xsl:if>
        </xsl:for-each>
        <!-- The maximum number of item charges to show on page 2 of the quarterly bill -->
        <xsl:variable name="maxItemisedCharges" select="30" />
        <!-- Calculate the number of lines for a message allowing only 2 lines per message. -->
        <xsl:variable name="messageLineCount" select="count($nodeParam/ContractBillMessage) * 2" />
        <!-- make allowance to display estimated message if it exists -->
        <xsl:variable name="estimatedMessageLine">
          <xsl:choose>
            <xsl:when test="$estimatedReading!=''">
              <xsl:value-of select="1" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="0" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- count Miscellaneous Bill Items and allow 2 lines for the heading -->
        <xsl:variable name="miscellaneousBillItemsCount">
          <xsl:choose>
            <xsl:when test="count($miscellaneousBillItems)>0">
              <xsl:value-of select="count($miscellaneousBillItems) + 2" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="0" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- on page 2 we need to show an itemised breakdown of bill charges -->
        <!-- Count all the devices, volume charges, miscellaneous, other payments, messages and add lines for Estimated Message and Headings -->
        <xsl:variable name="nonServiceItemCount"
          select="count($volumeBillItems) + count($volumeBillItems/Device) + $miscellaneousBillItemsCount + count($refundPayments) + count($returnTransferPayments) + count($goodwillPayments) + $messageLineCount + $estimatedMessageLine" />
        <!-- Set the maximum number of Itemised Service Charges to show on page 2 and display the remainder on page 3 -->
        <xsl:variable name="maxServiceCharges" select="$maxItemisedCharges - $nonServiceItemCount" />
        <xsl:variable name="headingDates" select="concat(' - ', new:dateFormat($nodeParam/StartDate), ' to ', new:dateFormat($nodeParam/EndDate))" />
        <!-- provide an itemised list of volume charges -->
        <xsl:if test="count($volumeBillItems) gt 0">
          <objectRecordList>
            <objectApiName>ItemisedVolumeCharges</objectApiName>
            <objectRecord>
              <objectApiName>ItemisedCharge</objectApiName>
              <field>
                <apiName>Heading</apiName>
                <value>
                  <xsl:value-of select="concat('Volume Charges', $headingDates)" />
                </value>
              </field>
              <objectRecord>
                <objectRecordList>
                  <objectApiName>BillItems</objectApiName>
                  <xsl:for-each select="$volumeBillItems">
                    <xsl:call-template name="itemisedCharges" />
                  </xsl:for-each>
                </objectRecordList>
              </objectRecord>
            </objectRecord>
          </objectRecordList>
        </xsl:if>
        <!-- provide an itemised list of miscellaneous charges which will include PDFChargeType of Miscellaneous and any other payments -->
        <xsl:if test="count($miscellaneousBillItems) gt 0 or $showOtherPayments">
          <objectRecordList>
            <objectApiName>ItemisedMiscellaneous</objectApiName>
            <objectRecord>
              <objectApiName>ItemisedCharge</objectApiName>
              <field>
                <apiName>Heading</apiName>
                <value>
                  <xsl:value-of select="concat('Miscellaneous', $headingDates)" />
                </value>
              </field>
              <objectRecord>
                <objectRecordList>
                  <objectApiName>BillItems</objectApiName>
                  <xsl:for-each select="$miscellaneousBillItems">
                    <xsl:call-template name="itemisedCharges" />
                  </xsl:for-each>
                  <xsl:for-each select="$goodwillPayments">
                    <objectRecord>
                      <objectApiName>BillItem</objectApiName>
                      <field>
                        <apiName>Description</apiName>
                        <value>
                          <xsl:value-of select="./Payment_Bill_Description" />
                        </value>
                      </field>
                      <field>
                        <apiName>Amount</apiName>
                        <value>
                          <xsl:value-of select="format-number(./Amount * -1, $totalFormat)" />
                        </value>
                      </field>
                    </objectRecord>
                  </xsl:for-each>
                  <xsl:for-each select="$refundPayments">
                    <objectRecord>
                      <objectApiName>BillItem</objectApiName>
                      <field>
                        <apiName>Description</apiName>
                        <value>Refund</value>
                      </field>
                      <field>
                        <apiName>Amount</apiName>
                        <value>
                          <xsl:value-of select="format-number(./Amount * -1, $totalFormat)" />
                        </value>
                      </field>
                    </objectRecord>
                  </xsl:for-each>
                  <xsl:for-each select="$returnTransferPayments">
                    <objectRecord>
                      <objectApiName>BillItem</objectApiName>
                      <field>
                        <apiName>Description</apiName>
                        <value>Return/Transfer</value>
                      </field>
                      <field>
                        <apiName>Amount</apiName>
                        <value>
                          <xsl:value-of select="format-number(./Amount * -1, $totalFormat)" />
                        </value>
                      </field>
                    </objectRecord>
                  </xsl:for-each>
                </objectRecordList>
              </objectRecord>
            </objectRecord>
          </objectRecordList>
        </xsl:if>
        <!-- provide an itemised list of serice charges -->
        <xsl:if test="count($serviceBillItems) gt 0">
          <objectRecordList>
            <objectApiName>ItemisedServiceCharges</objectApiName>
            <objectRecord>
              <objectApiName>ItemisedCharge</objectApiName>
              <field>
                <apiName>Heading</apiName>
                <value>
                  <xsl:value-of select="concat('Service+Charges', $headingDates)" />
                </value>
              </field>
              <xsl:if test="count($serviceBillItems) &gt; $maxServiceCharges">
                <field>
                  <apiName>ContinuedMessage</apiName>
                  <value>Continued&#8230;</value>
                </field>
              </xsl:if>
              <objectRecord>
                <objectRecordList>
                  <objectApiName>BillItems</objectApiName>
                  <xsl:for-each select="$serviceBillItems[position() &lt;= $maxServiceCharges]">
                    <xsl:call-template name="itemisedCharges" />
                  </xsl:for-each>
                </objectRecordList>
              </objectRecord>
            </objectRecord>
          </objectRecordList>
          <!-- if we have more service charges that will not fit on page 1 then create a second list to show them on page 3 -->
          <xsl:if test="count($serviceBillItems) &gt; $maxServiceCharges">
            <objectRecordList>
              <objectApiName>ItemisedServiceCharges2</objectApiName>
              <objectRecord>
                <objectApiName>ItemisedCharge</objectApiName>
                <field>
                  <apiName>Heading</apiName>
                  <value>
                    <xsl:value-of select="concat('&#8230;Continued Service Charges', $headingDates)" />
                  </value>
                </field>
                <objectRecord>
                  <objectRecordList>
                    <objectApiName>BillItems</objectApiName>
                    <xsl:for-each select="$serviceBillItems[position() &gt; $maxServiceCharges]">
                      <xsl:call-template name="itemisedCharges" />
                    </xsl:for-each>
                  </objectRecordList>
                </objectRecord>
              </objectRecord>
            </objectRecordList>
          </xsl:if>
        </xsl:if>
        <!-- add a total of the current charges for display on page 1 -->
        <!-- the total of Current Charge Amounts = (Service charges + Volume charges + Miscellaneous) + Other Payment Amounts - Discount Amounts -->
        <xsl:variable name="totalCurrentCharges" select="(sum($billItems/BilledAmount[number(.)=number(.)])  + $totalOtherPayments) - $totalDiscountAmount" />
        <field>
          <apiName>TotalCurrentCharges</apiName>
          <value>
            <xsl:value-of select="format-number($totalCurrentCharges, $totalFormat)" />
          </value>
        </field>
        <!-- Get the Opening Balance -->
        <field>
          <apiName>OpeningBalance</apiName>
          <value>
            <xsl:value-of select="format-number($balanceSnapshot,$totalFormat)" />
          </value>
        </field>
        <!-- Create the Opening Balance including any Payments for display on page 1 -->
        <xsl:variable name="openingBalanceLessPayments" select="$balanceSnapshot + $totalPayments" />
        <field>
          <apiName>OpeningBalanceLessPayments</apiName>
          <value>
            <xsl:value-of select="format-number($openingBalanceLessPayments, $totalFormat)" />
          </value>
        </field>
        <!-- the total amount due must be claculated even though it is provided in the data.xml -->
        <!-- Total Amount due is the Opening Balance less Payments + Total of Current Charge Amounts -->
        <field>
          <apiName>TotalAmountDue</apiName>
          <value>
            <xsl:value-of select="format-number($openingBalanceLessPayments + $totalCurrentCharges, $totalFormat)" />
          </value>
        </field>
        <!-- Constructing the Graph (Size of Graph must be adjusted in HTML) -->
        <objectRecord>
          <objectApiName>GraphData</objectApiName>
          <field>
            <apiName>GraphType</apiName>
            <value>BarChart</value>
          </field>
          <xsl:if test="$nodeParam/OldBills">
            <field>
              <apiName>GraphTitle</apiName>
              <value>Your Average daily usage in litres</value>
            </field>
          </xsl:if>
          <field>
            <apiName>xAxis</apiName>
            <value />
          </field>
          <field>
            <apiName>yAxis</apiName>
            <value />
          </field>
          <objectRecordList>
            <objectApiName>Data__c</objectApiName>
            <xsl:variable name="sorted_OldBills">
              <xsl:perform-sort select="$nodeParam/OldBills">
                <xsl:sort select="./OldBillStartDate" />
              </xsl:perform-sort>
            </xsl:variable>
            <xsl:variable name="billCount" select="count($sorted_OldBills/OldBills)-5" />
            <xsl:for-each select="$sorted_OldBills/OldBills[position() gt $billCount]">
              <objectRecord>
                <objectApiName>Data__c</objectApiName>
                <xsl:variable name="daysPerBill"
                  select="days-from-duration(xs:date(substring-before(normalize-space(./OldBillEndDate), '+')) - xs:date(substring-before(normalize-space(./OldBillStartDate), '+')))+1" />
                <field>
                  <apiName>DaysPerBill</apiName>
                  <value>
                    <xsl:value-of select="$daysPerBill" />
                  </value>
                </field>
                <field>
                  <apiName>AverageDailyUsage</apiName>
                  <xsl:choose>
                    <xsl:when test="./Total_Bill_Consumption_Water = ''">
                      <value>0.00</value>
                    </xsl:when>
                    <xsl:otherwise>
                      <value>
                        <xsl:value-of select="format-number((./Total_Bill_Consumption_Water div $daysPerBill) * 1000,$twoDecimalsNoCommasFormat)" />
                      </value>
                    </xsl:otherwise>
                  </xsl:choose>
                </field>
                <field>
                  <apiName>MonthName</apiName>
                  <value>
                    <xsl:value-of select="format-date(xs:date(substring-before(normalize-space(./OldBillEndDate), '+')),'[MNn,3-3]')" />
                  </value>
                </field>
              </objectRecord>
            </xsl:for-each>
          </objectRecordList>
        </objectRecord>
        <!-- end of graph block -->
        <!-- the contract balance is shown on page 1 as the Amount Due -->
        <field>
          <apiName>ContractBalance</apiName>
          <value>
            <xsl:value-of select="format-number($contractBalance, $totalFormat)" />
          </value>
        </field>
        <field>
          <apiName>DateOfIssue</apiName>
          <value>
            <xsl:value-of select="format-date(xs:date(substring-before(normalize-space($nodeParam/BillDate), '+')),$dateFormat)" />
          </value>
        </field>
        <!-- the target read date is displayed as the 'Next reading expected:' on the bill -->
        <xsl:for-each select="$volumeBillItems">
          <field>
            <apiName>TargetReadDate</apiName>
            <value>
              <xsl:value-of select="new:dateFormat(./BillItem_SP_TargetReadDate)" />
            </value>
          </field>
        </xsl:for-each>
        <!-- Get the Customers Name -->
        <field>
          <apiName>CustomerName</apiName>
          <value>
            <xsl:value-of select="$CustomerName" />
          </value>
        </field>
        <!-- Get the Contract Payment Reference for BPAY and Credit Cards -->
        <field>
          <apiName>BPayCRN</apiName>
          <value>
            <xsl:value-of select="$nodeParam/Contract_BPay_CRN" />
          </value>
        </field>
        <!-- Get the AusPost Reference -->
        <field>
          <apiName>AusPostCRN</apiName>
          <value>
            <xsl:value-of select="$nodeParam/Contract_AusPost_CRN" />
          </value>
        </field>
		<xsl:if test="$contractBalance > 0">
        <field>
          <apiName>AusPostBarcode</apiName>
          <value>
            <xsl:value-of select="$nodeParam/Contract_AusPost_Reference" />
          </value>
        </field>
        <field>
          <apiName>AusPostReference</apiName>
          <value>
            <xsl:value-of select="concat('*331', $nodeParam/Contract_AusPost_CRN)" />
          </value>
        </field>
		</xsl:if>
		
        <field>
          <apiName>CustomerReference</apiName>
          <value>
            <xsl:value-of select="$nodeParam/Contract_Name" />
          </value>
        </field>
        <!-- Get the Pay By Date -->
        <xsl:variable name="paymentDate" select="format-date($payByDate,$dateFormat)" />
        <xsl:variable name="paymentPlan" select="./Contract_CurrentPaymentPlanType_PlanType" />
        <xsl:variable name="paymentMethod" select="./Contract_PaymentMethodType" />
        <field>
          <apiName>PayBy</apiName>
          <xsl:choose>
            <xsl:when test="$contractBalance &lt;= 0">
              <value>
                <xsl:value-of select="'No payment required'" />
              </value>
            </xsl:when>
            <xsl:when test="$paymentPlan = 'Pay+In+Full' and $paymentMethod = 'Direct+Debit'">
              <value>
                <xsl:value-of select="concat($paymentDate, ' - Direct Debit')" />
              </value>
            </xsl:when>
            <xsl:when test="$paymentPlan = 'Budget+Plan'">
              <value>
                <xsl:value-of select="'Payment Plan'" />
              </value>
            </xsl:when>
            <xsl:otherwise>
              <value>
                <xsl:value-of select="$paymentDate" />
              </value>
            </xsl:otherwise>
          </xsl:choose>
        </field>
        <!-- Total Water Consumption in Kilolitres -->
        <xsl:if test="$waterConsumptionBillItemsTotalL &gt; 0">
          <field>
            <apiName>WaterConsumptionTotalLitres</apiName>
            <value>
              <xsl:value-of select="$waterConsumptionBillItemsTotalL" />
            </value>
          </field>
        </xsl:if>
        <!-- Average Daily Calculations -->
        <xsl:if test="not($volumeBillItems='') and not($volumeBillItems/Devices='')">
          <xsl:variable name="waterVolumeUsed" select="sum($volumeBillItems[contains(ServiceItem_ServiceItemType_ServiceItemFamily_ServiceType_Name, 'Water')]/VolumeUsed) * 1000" />
          <xsl:variable name="waterDaysUsed"
            select="days-from-duration(xs:date(substring-before(normalize-space($nodeParam/EndDate), '+')) - xs:date(substring-before(normalize-space($nodeParam/StartDate), '+')))+1" />
          <xsl:variable name="waterBilledAmount" select="sum($volumeBillItems[contains(ServiceItem_ServiceItemType_ServiceItemFamily_ServiceType_Name, 'Water')]/BilledAmount)" />
          <xsl:if test="$waterVolumeUsed > 0 and $waterDaysUsed > 0">
            <field>
              <apiName>AverageDailyUse</apiName>
              <value>
                <xsl:value-of select="format-number($waterVolumeUsed div $waterDaysUsed, $noDecimalsLDayFormat)" />
              </value>
            </field>
          </xsl:if>
          <xsl:if test="$waterBilledAmount > 0 and $waterDaysUsed > 0">
            <field>
              <apiName>AverageDailyCost</apiName>
              <value>
                <xsl:value-of select="format-number($waterBilledAmount div $waterDaysUsed, $totalFormat)" />
              </value>
            </field>
          </xsl:if>
        </xsl:if>
        <!-- Get the payment method of the account -->
        <field>
          <apiName>PaymentMethodType</apiName>
          <value>
            <xsl:value-of select="$nodeParam/Payment/PaymentMethod" />
          </value>
        </field>
        <field>
          <apiName>Address</apiName>
          <value>
            <xsl:value-of
              select="concat($nodeParam/Contract_BillingStreet,' ',$nodeParam/Contract_BillingCity,' ',$nodeParam/Contract_BillingState,' ',$nodeParam/Contract_PostalCode)" />
          </value>
        </field>
        <!-- Create the total tax -->
        <field>
          <apiName>TotalTax</apiName>
          <value>
            <xsl:value-of select="format-number($totalTax,$totalFormat)" />
          </value>
        </field>
        <!-- Create the total payment -->
        <field>
          <apiName>TotalPaymentsAmount</apiName>
          <value>
            <xsl:value-of select="new:minusZeroCheck($totalPayments)" />
          </value>
        </field>
        <!-- Calculate the Date of Total Payments Received Up To (Date of Issue - 1 Days) -->
        <field>
          <apiName>TotalPaymentsReceivedToDate</apiName>
          <value>
            <xsl:value-of select="format-date($totalPaymentsReceivedToCalculated,$dateFormat)" />
          </value>
        </field>
        <!-- Create the sundry bill -->
        <!-- The Sundry bill should list all BillItems plus all BillItem Discounts plus all Goodwill payments -->
        <xsl:variable name="sundryBillItems" select="$nodeParam/BillItem[ServiceItem_ServiceItemType_ServiceItemFamily_ServiceType_Name='Sundry']" />
        <!-- Put all the BillItems for display onto a list -->
        <xsl:variable name="displaySundryItems">
          <!-- Add The ordinary sundry Bill Items -->
          <xsl:for-each select="$sundryBillItems">
            <DisplayBillItem>
              <Description>
                <xsl:copy-of select="concat(./ServiceItem_ServiceItemType_BillDescription, ' ', ./ServiceItem_Invoice_Details)" />
              </Description>
              <Amount>
                <xsl:copy-of select="format-number(./BilledAmount, $totalFormat)" />
              </Amount>
            </DisplayBillItem>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="displaySundryItemsDiscounts">
          <!-- Add the BillItem Discounts -->
          <xsl:for-each select="$sundryBillItems">
            <!-- each BillItem can have multiple BillItemDiscounts -->
            <xsl:for-each select="./BillItemDiscount">
              <!-- <xsl:value-of select="new:log(.)" /> -->
              <DisplayBillItem>
                <Description>
                  <xsl:copy select="concat(./../ServiceItem_ServiceItemType_BillDescription, ' ', ./Discount/DiscountDetail)" />
                </Description>
                <Amount>
                  <xsl:copy select="format-number(./BillItemDiscountAmount, $totalFormat)" />
                </Amount>
              </DisplayBillItem>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="displayGoodwillPayments">
          <!-- Add the goodwill payments -->
          <xsl:for-each select="$goodwillPayments">
            <DisplayBillItem>
              <Description>
                <xsl:copy-of select="./Payment_Bill_Description" />
              </Description>
              <Amount>
                <xsl:copy-of select="format-number(./Amount * -1, $totalFormat)" />
              </Amount>
            </DisplayBillItem>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="displayBillItems" select="$displaySundryItems/DisplayBillItem, $displaySundryItemsDiscounts/DisplayBillItem, $displayGoodwillPayments/DisplayBillItem" />
        <!-- Create the Sundry Description Heading -->
        <xsl:variable name="singleSundryDescriptions" select="distinct-values($sundryBillItems[ServiceItem_SundryDescription!='']/ServiceItem_SundryDescription)" />
        <xsl:variable name="delim" select="' &amp; '" />
        <xsl:variable name="singleSundryDescription">
          <xsl:for-each select="$singleSundryDescriptions">
            <xsl:value-of select="concat($delim, normalize-space(.))" />
          </xsl:for-each>
        </xsl:variable>
        <!-- Total sundry bill items is billItems + billitems with discounts + goodwill items -->
        <!-- Create sundry Bill Items -->
        <xsl:variable name="maxSundryItems" select="3" />
        <!-- Create lists for each page -->
        <xsl:variable name="itemCountPage1" select="12" />
        <xsl:variable name="itemCountPage2" select="$itemCountPage1 + 24" />
        <!-- Add the Sundry bill items for display on the bill as required -->
        <xsl:variable name="pagesToDisplayCount">
          <xsl:choose>
            <xsl:when test="count($displayBillItems) &lt;= $itemCountPage1">
              <xsl:value-of select="'1'" />
            </xsl:when>
            <xsl:when test="count($displayBillItems) &gt; $itemCountPage1 and count($displayBillItems) &lt;= $itemCountPage2">
              <xsl:value-of select="'2'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'3'" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Create x number of pages of sundry bill items -->
        <!-- Create different totals block dependant upon the number of items for display -->
        <xsl:for-each select="1 to $pagesToDisplayCount">
          <!-- show sundry totals on page 1 if there is no page 2 -->
          <xsl:if test="position()=1 and count($displayBillItems) &lt;= $itemCountPage1">
            <xsl:call-template name="sundryTotals">
              <xsl:with-param name="sundryBillItems" select="$sundryBillItems" />
              <xsl:with-param name="pageNumber" select="'1'" />
            </xsl:call-template>
          </xsl:if>
          <!-- show sundry totals on page 2 if there is a page 2 and no page 3 -->
          <xsl:if test="position()=2 and count($displayBillItems) &lt;= $itemCountPage2">
            <xsl:call-template name="sundryTotals">
              <xsl:with-param name="sundryBillItems" select="$sundryBillItems" />
              <xsl:with-param name="pageNumber" select="'2'" />
            </xsl:call-template>
          </xsl:if>
          <!-- show sundry totals on page 3 if there is a page 3 -->
          <xsl:if test="position()=3 and count($displayBillItems) &gt; $itemCountPage2">
            <xsl:call-template name="sundryTotals">
              <xsl:with-param name="sundryBillItems" select="$sundryBillItems" />
              <xsl:with-param name="pageNumber" select="'3'" />
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>
        <!-- create sundry bill items for display dependant upon the number of items for each page -->
        <xsl:for-each select="1 to $pagesToDisplayCount">
          <objectRecordList>
            <objectApiName>
              <xsl:value-of select="concat('ItemisedSundryCharges', position())" />
            </objectApiName>
            <objectRecord>
              <xsl:variable name="heading">
                <xsl:choose>
                  <xsl:when test="position()=1">
                    <xsl:value-of select="substring-after($singleSundryDescription, $delim)" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'&#8230;Continued'" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <objectApiName>ItemisedCharge</objectApiName>
              <field>
                <apiName>Heading</apiName>
                <value>
                  <xsl:value-of select="$heading" />
                </value>
              </field>
              <objectRecord>
                <!-- break the list up for x bill items per page -->
                <objectRecordList>
                  <objectApiName>BillItems</objectApiName>
                  <xsl:choose>
                    <!-- create bill items for display on page 1 -->
                    <xsl:when test="position()=1">
                      <xsl:for-each select="$displayBillItems[position() &lt;= $itemCountPage1]">
                        <xsl:call-template name="itemisedSundryCharges">
                          <xsl:with-param name="description" select="./Description" />
                          <xsl:with-param name="amount" select="./Amount" />
                        </xsl:call-template>
                      </xsl:for-each>
                      <!-- conditionally place a continued message when there are Bill Items for page 2 -->
                      <xsl:if test="count($displayBillItems) &gt; $itemCountPage1">
                        <xsl:call-template name="itemisedSundryCharges">
                          <xsl:with-param name="description" select="'Continued&#8230;'" />
                          <xsl:with-param name="amount" select="''" />
                        </xsl:call-template>
                      </xsl:if>
                    </xsl:when>
                    <!-- create bill items for display on page 2 -->
                    <xsl:when test="position()=2">
                      <xsl:for-each select="$displayBillItems[position() &gt; $itemCountPage1 and position() &lt;= $itemCountPage2]">
                        <xsl:call-template name="itemisedSundryCharges">
                          <xsl:with-param name="description" select="./Description" />
                          <xsl:with-param name="amount" select="./Amount" />
                        </xsl:call-template>
                      </xsl:for-each>
                      <!-- conditionally add a continued message when there are Bill Items for page 3 -->
                      <xsl:if test="count($displayBillItems) &gt; ($itemCountPage1 + $itemCountPage2)">
                        <xsl:call-template name="itemisedSundryCharges">
                          <xsl:with-param name="description" select="'Continued&#8230;'" />
                          <xsl:with-param name="amount" select="''" />
                        </xsl:call-template>
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:for-each select="$displayBillItems[position() &gt; $itemCountPage2]">
                        <xsl:call-template name="itemisedSundryCharges">
                          <xsl:with-param name="description" select="./Description" />
                          <xsl:with-param name="amount" select="./Amount" />
                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:otherwise>
                  </xsl:choose>
                </objectRecordList>
              </objectRecord>
            </objectRecord>
          </objectRecordList>
        </xsl:for-each>
        <!-- Create the contract message Section -->
        <objectRecordList>
          <objectApiName>ContractBillMessages</objectApiName>
          <xsl:for-each select="$nodeParam/ContractBillMessage">
            <objectRecord>
              <objectApiName>ContractBillMessage</objectApiName>
              <field>
                <apiName>BillMessage_MessageText</apiName>
                <value>
                  <xsl:value-of select="new:truncate(.,200)" />
                </value>
              </field>
              <!-- <xsl:call-template name="fieldsTemplate" /> -->
            </objectRecord>
          </xsl:for-each>
        </objectRecordList>
      </objectRecord>
      <!-- Email params -->
      <xsl:if test="$billing_email_opt_in_param = 'true'">
        <emailTemplateData>
          <emailTemplateName>
            <xsl:value-of select="$nodeParam/EmailTemplateName" />
          </emailTemplateName>
          <to>
            <xsl:value-of select="$account_email_param" />
          </to>
          <from>
            <xsl:value-of select="$nodeParam/FromEmail" />
          </from>
          <attachment>
            <xsl:value-of select="$nodeParam/EmailAttachmentType" />
          </attachment>
          <field>
            <apiName>FirstName</apiName>
            <value>
              <xsl:value-of select="$CustomerName" />
            </value>
          </field>
          <field>
            <apiName>DueDate</apiName>
            <value>
              <xsl:value-of select="format-date($payByDate,$dateFormat)" />
            </value>
          </field>
          <field>
            <apiName>AmountDue</apiName>
            <value>
              <xsl:value-of select="format-number($contractBalance,$totalFormat)" />
            </value>
          </field>
          <field>
            <apiName>PaymentURL</apiName>
            <value>
              <xsl:value-of select="$nodeParam/Contract_CustomerPaymentURL" />
            </value>
          </field>
          <field>
            <apiName>PropertyAddress</apiName>
            <value>
              <xsl:value-of select="concat($addressLocation/Street, ' ',$addressLocation/City, ' ',$addressLocation/State, ' ',$addressLocation/PostalCode)" />
            </value>
          </field>
          <field>
            <apiName>UnsubscribeLink</apiName>
            <value>
              <xsl:value-of select="$billing_email_opt_out_link_param" />
            </value>
          </field>
        </emailTemplateData>
      </xsl:if>
    </pdfData>
  </xsl:template>
  <!-- Create itemised charges -->
  <xsl:template name="itemisedCharges">
    <xsl:param name="node" select="." />
    <xsl:variable name="chargeType" select="new:stripSpaces(new:decode($node/ServiceItem_ServiceItemType_PDFChargeType))" />
    <xsl:variable name="billDescription" select="new:decode($node/ServiceItem_ServiceItemType_BillDescription)" />
    <xsl:variable name="rateRetailAmount" select="$node/Rate_RetailAmount" />
    <xsl:variable name="agreedRate" select="$node/BillItem_AgreedRate" />
    <xsl:variable name="majorCustomer">
      <xsl:if test="not($node/BillItem_AgreedRate = '')">
        <xsl:value-of select="'Major Customer '" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="billItemDescription" select="new:decode($node/ServiceItem_ServiceItemType_BillDescription)" />
    <!-- <xsl:value-of select="new:log($billItemDescription)" /> -->
    <objectRecord>
      <objectApiName>BillItem</objectApiName>
      <field>
        <apiName>Description</apiName>
        <xsl:if test="$chargeType='VolumeCharge' and $node/Device/Name!=''">
          <xsl:variable name="regularConsumption" select="$node/VolumeUsed" />
          <xsl:variable name="selectWaterRate" select="new:selectWaterRate($rateRetailAmount,$agreedRate)" />
          <xsl:variable name="waterConsumption">
            <xsl:choose>
              <xsl:when test="$regularConsumption &gt; 1">
                <xsl:value-of select="format-number($regularConsumption, $noDecimalsFormat)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="format-number($regularConsumption, $twoDecimalsFormat)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="waterRate" select="format-number($selectWaterRate * 100, $twoDecimalsFormat)" />
          <value>
            <xsl:value-of select="concat($billDescription, ' ', $majorCustomer, '(', $waterConsumption, 'kL @ ', $waterRate, ' c/kL)')" />
          </value>
        </xsl:if>
        <xsl:if test="$chargeType='ServiceCharge'">
          <xsl:variable name="rateDividedByYear" select="new:rateDividedByYear(./Rate_LeapYear, $agreedRate, $rateRetailAmount)" />
          <value>
            <xsl:value-of select="concat($billDescription, ' (', ./NumberOfDays, ' days @ ', $rateDividedByYear, 'c)')" />
          </value>
        </xsl:if>
        <xsl:if test="$chargeType='Miscellaneous'">
          <value>
            <xsl:value-of select="$billItemDescription" />
          </value>
        </xsl:if>
      </field>
      <field>
        <apiName>Amount</apiName>
        <value>
          <xsl:value-of select="format-number($node/BilledAmount, $totalFormat)" />
        </value>
      </field>
    </objectRecord>
  </xsl:template>
  <xsl:template name="itemisedSundryCharges">
    <xsl:param name="description" />
    <xsl:param name="amount" />
    <objectRecord>
      <objectApiName>BillItem</objectApiName>
      <field>
        <apiName>Description</apiName>
        <value>
          <xsl:value-of select="$description" />
        </value>
      </field>
      <field>
        <apiName>Amount</apiName>
        <value>
          <xsl:value-of select="$amount" />
        </value>
      </field>
    </objectRecord>
  </xsl:template>
  <!-- Create fields of object record -->
  <xsl:template name="fieldsTemplate">
    <xsl:for-each select="node()">
      <xsl:if test="name(.) !=''">
        <xsl:choose>
          <xsl:when test="*" />
          <xsl:otherwise>
            <xsl:call-template name="fieldTemplate" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  <!-- Sundry totals -->
  <xsl:template name="sundryTotals">
    <!-- Create the total charge -->
    <xsl:param name="sundryBillItems" />
    <xsl:param name="pageNumber" />
    <xsl:variable name="totalChargeSundry" select="sum($sundryBillItems/BilledAmount[number(.) = number(.)])" />
    <xsl:variable name="totalDiscountSundry" select="sum($sundryBillItems/BillItemDiscount/BillItemDiscountAmount[number(.) = number(.)])" />
    <objectRecordList>
      <objectApiName>
        <xsl:value-of select="concat('SundryTotalsPage',$pageNumber)" />
      </objectApiName>
      <objectRecord>
        <objectApiName>SundryTotals</objectApiName>
        <field>
          <apiName>TotalChargeAmount</apiName>
          <value>
            <xsl:value-of select="format-number(sum($totalChargeSundry + $totalDiscountSundry),$totalFormat)" />
          </value>
        </field>
        <!-- Create the total discount -->
        <xsl:variable name="totalDiscountSundry" select="sum($sundryBillItems/TotalDiscountAmount[number(.) = number(.)])" />
        <field>
          <apiName>TotalDiscountAmountSundry</apiName>
          <value>
            <xsl:value-of select="format-number($totalDiscountSundry,$totalFormat)" />
          </value>
        </field>
        <!-- Create the total tax -->
        <xsl:variable name="totalTaxSundry" select="sum($sundryBillItems/TotalTaxAmount[number(.) = number(.)])" />
        <field>
          <apiName>TotalTaxSundry</apiName>
          <value>
            <xsl:value-of select="format-number($totalTaxSundry,$totalFormat)" />
          </value>
        </field>
      </objectRecord>
    </objectRecordList>
  </xsl:template>
  <!-- Create object record list -->
  <xsl:template name="listTemplate">
    <xsl:variable name="list" select="node()" />
    <xsl:for-each-group select="$list" group-by="name(.)">
      <xsl:if test="name(.) !=''">
        <xsl:choose>
          <xsl:when test="*">
            <xsl:variable name="tagName" select="name(.)" />
            <objectRecordList>
              <objectApiName>
                <xsl:value-of select="name(.)" />
              </objectApiName>
              <xsl:for-each select="$list">
                <xsl:if test="name(.) = $tagName">
                  <objectRecord>
                    <objectApiName>
                      <xsl:value-of select="name(.)" />
                    </objectApiName>
                    <xsl:call-template name="fieldsTemplate" />
                  </objectRecord>
                </xsl:if>
              </xsl:for-each>
            </objectRecordList>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:template>
  <!-- Create field -->
  <xsl:template name="fieldTemplate">
    <field>
      <apiName>
        <xsl:value-of select="name(.)" />
      </apiName>
      <value>
        <xsl:choose>
          <xsl:when test="matches(normalize-space(.), '(\d{4})\D(\d{2})\D(\d{2})')">
            <xsl:value-of select="substring-before(normalize-space(.), '+')" />
          </xsl:when>
          <xsl:when test="matches(normalize-space(.), '^\d+\.\d{0,2}') and number(.) = number(.)">
            <xsl:value-of select="format-number(.,$totalFormat)" />
          </xsl:when>
          <xsl:when test="matches(normalize-space(.), '^\-\d*\.\d{0,2}') and number(.) = number(.)">
            <xsl:value-of select="format-number(number(translate(., '-','')),$creditFormat)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </value>
    </field>
  </xsl:template>
</xsl:transform>

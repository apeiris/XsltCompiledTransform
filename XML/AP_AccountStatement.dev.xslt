<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:new="https://www.newater.com.au/" version="2.0">
  <xsl:output method="xml" indent="yes" encoding="UTF-8" />
  <xsl:variable name="totalFormat" select="'$###,##0.00'" />
  <xsl:variable name="fourDecimalsTotalFormat" select="'$###,##0.0000'" />
  <xsl:variable name="threeDecimalsFormatKL" select="'###,##0.000 kL'" />
  <xsl:variable name="noDecimalsFormat" select="'0'" />
  <xsl:variable name="noDecimalsLDayFormat" select="'0 L/day'" />
  <xsl:variable name="dateFormat" select="'[D] [MNn,3-3] [Y0001]'" />
  <xsl:variable name="dateFormatOrdinal" select="'[Y0001][M01][D01]'" />
  <xsl:variable name="dateFormatBreakdown" select="'[D01]-[M01]-[Y0001]'" />
  <xsl:variable name="dateFormatPayBy" select="'[D01] [MNn] [Y0001]'" />
  <xsl:variable name="dateFormatNextInstalment" select="'[D] [MNn,3-3] [Y0001]'" />
  <xsl:variable name="dateFormatShort" select="'[D01]/[M01]/[Y01]'" />
  <xsl:variable name="dateToday" select="format-date(current-date(), $dateFormatBreakdown)" />
  <xsl:variable name="dateTodayFormatted" select="format-date(current-date(), $dateFormat)" />
  <xsl:variable name="dateTodayOrdinal" select="format-date(current-date(), $dateFormatOrdinal)" />
  <xsl:variable name="dateYesterday" select="format-date(current-date() - xs:dayTimeDuration('P1D'), $dateFormatBreakdown)" />
  <xsl:variable name="dateYesterdayFormatted" select="format-date(current-date() - xs:dayTimeDuration('P1D'), $dateFormat)" />
  <xsl:variable name="dateYesterdayFormattedShort" select="format-date(current-date() - xs:dayTimeDuration('P1D'), $dateFormatShort)" />
  <xsl:function name="new:log">
    <!-- a convenience method to help debuggi   ng -->
    <xsl:param name="message" />
    <xsl:message>
      <xsl:value-of select="$message" />
    </xsl:message>
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
        <xsl:value-of select="'No Date'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <xsl:template match="PDFRequest">
    <pdfData>
      <xsl:variable name="CustomerName">
        <!-- Get the Customers Name -->
        <xsl:variable name="billPrintName1" select="new:truncate(./Contract_Bill_Print_Name_1, 40)" />
        <xsl:variable name="billPrintName2" select="new:truncate(./Contract_Bill_Print_Name_2, 40)" />
        <xsl:choose>
          <xsl:when test="($billPrintName1 != '') and ($billPrintName2 != '')">
            <xsl:value-of select="concat($billPrintName1,'&lt;br/&gt;',$billPrintName2)" />
          </xsl:when>
          <xsl:when test="$billPrintName1 != ''">
            <xsl:value-of select="$billPrintName1" />
          </xsl:when>
          <!-- catch if no bill print name is available -->
          <xsl:otherwise>
            <xsl:value-of select="new:truncate(./Account_Name, 40)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <pdfTemplateName>
        <xsl:value-of select="./PdfTemplateName" />
      </pdfTemplateName>
      <!-- Get the Customers Name -->
      <!--Create 'Statement' objectRecord -->
      <objectRecord>
        <objectApiName>Statement</objectApiName>
        <field>
          <apiName>CustomerName</apiName>
          <value>
            <xsl:value-of select="$CustomerName" />
          </value>
        </field>
        <!--Get last AddressLocation -->
        <xsl:variable name="accountAddressLocation" select="(./Service/SupplyPoint/Location)[last()]" />
        <field>
          <apiName>PropertyAddress</apiName>
          <value>
            <xsl:value-of
              select="concat($accountAddressLocation/Street, ' ', $accountAddressLocation/City, ' ', $accountAddressLocation/State, ' ', $accountAddressLocation/PostalCode)" />
          </value>
        </field>
        <!--Get DateOfIssue (currentdate) -->
        <field>
          <apiName>DateOfIssue</apiName>
          <value>
            <xsl:value-of select="$dateTodayFormatted" />
          </value>
        </field>
        <xsl:variable name="futureInstalments"
          select="./PaymentPlan/Instalment[xs:integer(translate(substring-before(xs:string(InstalmentDueDate), '+'), '-', '')) > xs:integer($dateTodayOrdinal)]" />
        <!-- Sort the Instalments by InstalmentNumber just in case Instalment nodes arrive out of order -->
        <xsl:variable name="sortedFutureInstalments">
          <xsl:for-each select="$futureInstalments">
            <xsl:sort select="InstalmentNumber" data-type="number" order="ascending" />
            <xsl:copy-of select="." />
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="currentInstalment" select="$sortedFutureInstalments/Instalment[1]" />
        <xsl:variable name="nextInstalment" select="$sortedFutureInstalments/Instalment[2]" />
        <xsl:variable name="nextInstalmentDueDate" select="substring-before($nextInstalment/InstalmentDueDate, '+')" />
        <field>
          <apiName>NextInstalmentDate</apiName>
          <value>
            <xsl:if test="$nextInstalmentDueDate != ''">
              <xsl:value-of select="format-date(xs:date($nextInstalmentDueDate), $dateFormatNextInstalment)" />
            </xsl:if>
          </value>
        </field>
        <!-- Format the Account Number -->
        <field>
          <apiName>AccountNumber</apiName>
          <value>
            <xsl:value-of select="./Contract_Name" />
          </value>
        </field>
        <!-- Get Billing Street as addressline1 -->
        <xsl:variable name="address_param_line1" select="./Contract_BillingStreet" />
        <field>
          <apiName>AddressLine1</apiName>
          <value>
            <xsl:value-of select="$address_param_line1" />
          </value>
        </field>
        <!--Concat Billing City, State and PostalCode as addressline2 -->
        <xsl:variable name="address_param_line2" select="concat(./Contract_BillingCity,' ',./Contract_BillingState,' ',./Contract_BillingPostalCode)" />
        <field>
          <apiName>AddressLine2</apiName>
          <value>
            <xsl:value-of select="$address_param_line2" />
          </value>
        </field>
        <xsl:variable name="statementEndDate" select="xs:date(normalize-space(./Account_Statement_EndDate))" />
        <!-- TODO: work out why new:timeStampToDate(./Account_Statement_EndDate) throws an error when adding payByDate -->
        <xsl:variable name="payByDate" select="$statementEndDate+xs:dayTimeDuration('P28D')" />
        <field>
          <apiName>PayBy</apiName>
          <value>
            <xsl:value-of select="format-date($payByDate,$dateFormat)" />
          </value>
        </field>
        <!-- Get the start and end dates from the data when they are mapped -->
        <xsl:variable name="balanceTransactionsToDate" select="new:timeStampToDate(./Account_Statement_EndDate)" />
        <xsl:variable name="balanceTransactionsFromDate" select="new:timeStampToDate(./Account_Statement_StartDate)" />
        <field>
          <apiName>Period</apiName>
          <value>
            <xsl:value-of select="concat(format-date($balanceTransactionsFromDate,$dateFormat), ' to ',format-date($balanceTransactionsToDate,$dateFormat))" />
          </value>
        </field>
        <!-- Get the balance transactions between the from and to dates -->
        <xsl:variable name="balanceTransactions"
          select="./Balance/BalanceTransaction[(xs:integer(translate(substring-before(xs:string(TransactionDate), '+'), '-', '')) >= 
							  								        xs:integer(format-date(xs:date($balanceTransactionsFromDate), $dateFormatOrdinal))) and 
																   (xs:integer(translate(substring-before(xs:string(TransactionDate), '+'), '-', '')) &lt;= 
							  								        xs:integer(format-date(xs:date($balanceTransactionsToDate), $dateFormatOrdinal)))]" />
        <!-- Construct a list of transactions with credits and debits and order them by date -->
        <!-- Sort the BalanceTransactions by date to put them in latest to earliest order -->
        <xsl:variable name="dateDescendingeBalanceTransactions">
          <xsl:for-each select="$balanceTransactions">
            <xsl:sort select="TransactionDate" data-type="text" order="descending" />
            <xsl:copy-of select="." />
          </xsl:for-each>
        </xsl:variable>
        <!-- Make a duplicate structure of the dateDescendingeBalanceTransactions with numbers in all of the relevant fields instead of empty tags so that they can be summed across all sibling 
          nodes. -->
        <xsl:variable name="balanceTransactionsWithNumbers">
          <xsl:for-each select="$dateDescendingeBalanceTransactions/BalanceTransaction">
            <BalanceTransaction>
              <TransactionDate>
                <xsl:value-of select="TransactionDate" />
              </TransactionDate>
              <RecordTypeName>
                <xsl:value-of select="RecordTypeName" />
              </RecordTypeName>
              <BillNumber>
                <xsl:value-of select="BillNumber" />
              </BillNumber>
              <BillAmount>
                <xsl:choose>
                  <xsl:when test="not(BillAmount) or (BillAmount = '')">
                    0
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="BillAmount" />
                  </xsl:otherwise>
                </xsl:choose>
              </BillAmount>
              <PaymentAmount>
                <xsl:choose>
                  <xsl:when test="not(PaymentAmount) or (PaymentAmount = '')">
                    0
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="PaymentAmount" />
                  </xsl:otherwise>
                </xsl:choose>
              </PaymentAmount>
              <ReturnTransferAmount>
                <xsl:choose>
                  <xsl:when test="not(ReturnTransferAmount) or (ReturnTransferAmount = '')">
                    0
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="ReturnTransferAmount" />
                  </xsl:otherwise>
                </xsl:choose>
              </ReturnTransferAmount>
              <PendingBillAmount>
                <xsl:choose>
                  <xsl:when test="not(PendingBillAmount) or (PendingBillAmount = '')">
                    0
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="PendingBillAmount" />
                  </xsl:otherwise>
                </xsl:choose>
              </PendingBillAmount>
              <RefundAmount>
                <xsl:choose>
                  <xsl:when test="not(RefundAmount) or (RefundAmount = '')">
                    0
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="RefundAmount" />
                  </xsl:otherwise>
                </xsl:choose>
              </RefundAmount>
            </BalanceTransaction>
          </xsl:for-each>
        </xsl:variable>
        <!--Calculate CreditTotal -->
        <xsl:variable name="totalCredits"
          select="sum($balanceTransactionsWithNumbers/BalanceTransaction/PaymentAmount) + sum($balanceTransactionsWithNumbers/BalanceTransaction/RefundAmount)" />
        <field>
          <apiName>CreditTotal</apiName>
          <value>
            <xsl:value-of select="format-number($totalCredits, $totalFormat)" />
          </value>
        </field>
        <!-- Get the Balance -->
        <xsl:variable name="balanceBalance" select="./Balance/Balance" />
        <field>
          <apiName>Balance</apiName>
          <value>
            <xsl:value-of select="format-number($balanceBalance, $totalFormat)" />
          </value>
        </field>
        <xsl:if test="number($balanceBalance) lt 0">
          <field>
            <apiName>NegativeBalanceMessage</apiName>
            <value>Account in credit, no payment required</value>
          </field>
        </xsl:if>
        <!-- Get the interest transactions -->
        <xsl:variable name="interestTransactions" select="./Balance/BalanceTransaction[RecordTypeName = 'Bill']" />
        <!-- Sort the list so that the lowest BillNumber is last -->
        <xsl:variable name="sortedInterestTransactions">
          <xsl:for-each select="$interestTransactions">
            <xsl:sort select="BillNumber" data-type="text" order="descending" />
            <xsl:copy-of select="." />
          </xsl:for-each>
        </xsl:variable>
        <!-- Get the first BalanceTransaction -->
        <xsl:variable name="firstInterestTransaction" select="$sortedInterestTransactions/BalanceTransaction[last()]" />
        <xsl:variable name="schemeOpeningBalance">
          <xsl:choose>
            <xsl:when test="not($firstInterestTransaction/BillAmount) or ($firstInterestTransaction/BillAmount = '')">
              0
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$firstInterestTransaction/BillAmount" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Get the Opening Balance -->
        <field>
          <apiName>OpeningBalance</apiName>
          <value>
            <xsl:value-of select="format-number($schemeOpeningBalance, $totalFormat)" />
          </value>
        </field>
        <xsl:variable name="schemeTotalAmountDue">
          <xsl:choose>
            <xsl:when test="xs:string($currentInstalment/InstalmentAmountDue) = ''">
              0
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$currentInstalment/InstalmentAmountDue" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$schemeTotalAmountDue!=''">
          <field>
            <apiName>CurrentPayableInstalment</apiName>
            <value>
              <xsl:value-of select="format-number($schemeTotalAmountDue, $totalFormat)" />
            </value>
          </field>
        </xsl:if>
        <xsl:variable name="currentInstalmentDueDate" select="substring-before($currentInstalment/InstalmentDueDate, '+')" />
        <field>
          <apiName>InstalmentPayBy</apiName>
          <value>
            <xsl:if test="$currentInstalmentDueDate != ''">
              <xsl:value-of select="format-date(xs:date($currentInstalmentDueDate), $dateFormatPayBy)" />
            </xsl:if>
          </value>
        </field>
        <field>
          <apiName>CurrentInstalmentNumber</apiName>
          <value>
            <xsl:value-of select="concat($currentInstalment/InstalmentNumber, ' of ', count(./PaymentPlan/Instalment))" />
          </value>
        </field>
        <!--Calculate DebitTotal -->
        <xsl:variable name="totalDebits"
          select="sum($balanceTransactionsWithNumbers/BalanceTransaction/BillAmount) + sum($balanceTransactionsWithNumbers/BalanceTransaction/ReturnTransferAmount)" />
        <field>
          <apiName>DebitTotal</apiName>
          <value>
            <xsl:value-of select="format-number($totalDebits, $totalFormat)" />
          </value>
        </field>
        <!--Get TransactionCount -->
        <xsl:variable name="transactionCount" select="count($balanceTransactionsWithNumbers/BalanceTransaction)" />
        <field>
          <apiName>TransactionCount</apiName>
          <value>
            <xsl:value-of select="$transactionCount" />
          </value>
        </field>
        <!-- Create the Payment Codes -->
        <xsl:variable name="node_param" select="." />
        <!-- Get the Contract Payment Reference for BPAY and Credit Cards -->
        <field>
          <apiName>BPayCRN</apiName>
          <value>
            <xsl:value-of select="$node_param/Contract_BPay_CRN" />
          </value>
        </field>
        <!-- Get the AusPost Reference -->
        <field>
          <apiName>AusPostCRN</apiName>
          <value>
            <xsl:value-of select="$node_param/Contract_AusPost_CRN" />
          </value>
        </field>
        <field>
          <apiName>AusPostBarcode</apiName>
          <value>
            <xsl:value-of select="$node_param/Contract_AusPost_Reference" />
          </value>
        </field>
        <field>
          <apiName>AusPostReference</apiName>
          <value>
            <xsl:value-of select="concat('*331', $node_param/Contract_AusPost_CRN)" />
          </value>
        </field>
        <!--Create AccountTransactions objectRecordList and objectRecord -->
        <!-- TODO: Jira 2088 Add BillItems for Bill, do not show Bill amount -->
        <xsl:variable name="bills" select="Bill" />
        <!-- <xsl:value-of select="new:log($bills)" /> -->
        <objectRecordList>
          <xsl:for-each select="$balanceTransactionsWithNumbers/BalanceTransaction">
            <!-- Changing to descending **AP**-->
            <xsl:sort select="TransactionDate" data-type="text" order="descending" />
            <xsl:choose>
              <xsl:when test="RecordTypeName='Bill'">
                <xsl:variable name="transactionDate" select="TransactionDate" />
                <xsl:variable name="balanceTransactionBillNumber" select="BillNumber" />
                <xsl:for-each select="$bills[BillNumber=$balanceTransactionBillNumber]">
                  <xsl:for-each select="./BillItem">
                    <objectApiName>AccountTransactions</objectApiName>
                    <objectRecord>
                      <objectApiName>AccountTransaction</objectApiName>
                      <field>
                        <apiName>Date</apiName>
                        <value>
                          <xsl:if test="position() = 1">
                            <xsl:value-of select="new:dateFormat($transactionDate)" />
                          </xsl:if>
                        </value>
                      </field>
                      <field>
                        <apiName>TransactionType</apiName>
                        <value>
                    <!--      <xsl:value-of select="./ServiceItem_ServiceItemType_BillDescription" /> -->
                          <xsl:value-of select="../BillNumber" />
                        </value>
                            </field>
						<this is="" to="" test="" git="">
							
						</this>                      <field>
                        <apiName>Debit</apiName>
                        <value>
                          <xsl:value-of select="format-number(./NetBilledAmount, $totalFormat)" />
                        </value>
                      </field>
                      <field>
                        <apiName>Credit</apiName>
                        <value />
                      </field>
                    </objectRecord>
                  </xsl:for-each>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <objectApiName>AccountTransactions</objectApiName>
                <objectRecord>
                  <objectApiName>AccountTransaction</objectApiName>
                  <field>
                    <apiName>Date</apiName>
                    <value>
                      <xsl:value-of select="new:dateFormat(TransactionDate)" />
                    </value>
                  </field>
                  <field>
                    <apiName>TransactionType</apiName>
                    <value>
                      <xsl:value-of select="RecordTypeName" />
                    </value>
                  </field>
                  <field>
                    <apiName>TransactionReference</apiName>
                    <value>
                      <xsl:if test="not(BillNumber) or BillNumber != ''">
                        <xsl:value-of select="BillNumber" />
                      </xsl:if>
                    </value>
                  </field>
                  <field>
                    <apiName>Debit</apiName>
                    <value>
                      <xsl:if test="normalize-space(BillAmount) != '0'">
                        <xsl:value-of select="format-number(BillAmount, $totalFormat)" />
                      </xsl:if>
                      <xsl:if test="normalize-space(ReturnTransferAmount) != '0'">
                        <xsl:value-of select="format-number(ReturnTransferAmount, $totalFormat)" />
                      </xsl:if>
                    </value>
                  </field>
                  <field>
                    <apiName>Credit</apiName>
                    <value>
                      <xsl:if test="normalize-space(PaymentAmount) != '0'">
                        <xsl:value-of select="format-number(PaymentAmount, $totalFormat)" />
                      </xsl:if>
                      <xsl:if test="normalize-space(RefundAmount) != '0'">
                        <xsl:value-of select="format-number(RefundAmount, $totalFormat)" />
                      </xsl:if>
                    </value>
                  </field>
                </objectRecord>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </objectRecordList>
        <xsl:call-template name="fieldsTemplate" />
      </objectRecord>
    </pdfData>
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
          <xsl:otherwise>
            <xsl:value-of select="." />
          </xsl:otherwise>
        </xsl:choose>
      </value>
    </field>
  </xsl:template>
</xsl:transform>
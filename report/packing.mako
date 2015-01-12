<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Untitled Document</title>
</head>

<body>
%for picking in objects:
<div align="center">
    <table bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" width="650">
        <tbody>
            <tr>
                <td align="center" valign="top"><a href="http://www.bitsoflace.com/" target="_blank"><img height="175" width="175" src="http://www.bitsoflace.com/media/BOL-revised.png" alt="Bits of Lace" border="0" /></a></td>
            </tr>
            <tr style="font-size: 24px; font-weight:bold;">
                <td valign="bottom">Hello, ${picking.partner_id.name}</td>
            </tr>
            <tr style="font-size: 24px; font-weight:bold;">
                <td valign="top">Your Order ${picking.sale.name or picking.name} Has Shipped.</td>
            </tr>
            <tr>
                <td>
                    <p>If you have any questions about your order please contact us at <a href="mailto:support@bitsoflace.com" target="_blank">support@bitsoflace.com</a> or call us at <a href="tel:%28800%29%20842-3990" value="+18008423990" target="_blank">(800) 842-3990</a> <span tabindex="0" data-term="goog_1634436882">Monday</span> - <span tabindex="0" data-term="goog_1634436883">Friday, 8am - 5pm PST</span>. </p>
                    <p>Your shipping confirmation is below.</p>
                </td>
            </tr>
            <tr>
                <td>
                    <table style="border: double grey 2px; border-collapse: collapse; border-spacing: 5px;" cellpadding="0" cellspacing="0" width="650">
                        <thead>
                            <tr height="35px" style="font-size: 16px; background-color: grey; color: white; font-weight:bold;">
                                <th style="padding: 5px; border: solid grey 1px;" align="left" width="325">Bill To</th>
                                <th style="padding: 5px; border: solid grey 1px;" align="left" width="325">Tracking Number(s)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr height="35px" >
                                <td valign="top" style="padding: 5px; border: solid grey 1px;">${picking.sale.partner_invoice_id.name}<br />
                                  ${picking.sale.partner_invoice_id.street or ''}<br/>
				  %if picking.sale.partner_invoice_id.street2:
                                      ${picking.partner_id.street2 or ''}<br/>
				  %endif
                                  ${picking.sale.partner_invoice_id.city or ''}, ${picking.partner_id.state_id.code or ''} ${picking.partner_id.zip or ''}<br />
                                  United States<br/>
                                  
                                </td>
                                <td valign="top" style="padding: 5px; border: solid grey 1px;">
				    %for package in picking.packages:
					%if package.tracking_number:
					    <div><a href="${create_tracking_link(package.tracking_number)}" target="_blank">${package.tracking_number}</a></div>
					%endif
				    %endfor
				</td>
                            </tr>
                        </tbody>
                    </table>
                    <div style="clear: both;"><br/></div>
                    <table style="border: double grey 2px; border-collapse: collapse; border-spacing: 5px;" cellpadding="0" cellspacing="0" width="650">
                        <thead>
                            <tr height="35px" style="font-size: 16px; background-color: grey; color: white; font-weight:bold;">
                                <th style="padding: 5px;" align="left" width="325">Ship To</th>
                                <th style="padding: 5px;" align="left" width="325">Ship Via</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td valign="top" style="padding: 5px; border: solid grey 1px;">${picking.partner_id.name}<br />
                                  ${picking.partner_id.street or ''}<br/>
				  %if picking.partner_id.street2:
                                      ${picking.partner_id.street2 or ''}<br/>
				  %endif
                                  ${picking.partner_id.city or ''}, ${picking.partner_id.state_id.code or ''} ${picking.partner_id.zip or ''}<br />
                                  United States<br/>
                                  </td>
                                <td valign="top" style="padding: 5px; border: solid grey 1px;"> ${picking.carrier_id.name or ''}</td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
	    <% orderlines = paginate_items(cr, picking.move_lines) %>
            <tr>
                <table style="border: double grey 2px; border-collapse: collapse; border-spacing: 5px;" cellpadding="0" cellspacing="0" width="650">
                    <thead>
                      <br/>
                        <tr height="35px" style="background-color: grey; color: white; font-weight:bold;">
                            <th style="padding: 5px;" align="left" width="250">Style Number/Name</th>
                            <th style="padding: 5px;" align="left" width="100">On Order</th>
                            <th style="padding: 5px;" align="left" width="100">Shipped</th>
                            <th style="padding: 5px;" align="left" width="100">Backorder</th>
                            <th style="padding: 5px;" align="left" width="100">Ships On</th>
                        </tr>
                    </thead>
                    <tbody>
			%for line in orderlines:
                        <tr>
                            <td valign="top">
                              <div style="padding-left: 5px; padding-top: 5px;"><strong>${line['sku']}</strong></div>
                              <div style="padding-left: 5px;">${line['description']}</div>
                            </td>
                            <td style="padding: 5px; text-align:center;" valign="top">${line['qty_order']}</td>
                            <td style="padding: 5px; text-align:center;" valign="top">${line['qty_ship']}</td>
                            <td style="padding: 5px; text-align:center;" valign="top">${line['qty_backorder']}</td>
                            <td style="padding: 5px; text-align:center;" valign="top">${line['expected_ship_date']}</td>
                        </tr>
			%endfor
                    </tbody>
                </table>
            </tr>
        </tbody>
    </table>
    <div style="clear: both;"><br/></div>
    <table style="border: double grey 2px; border-collapse: collapse; border-spacing: 5px;" cellpadding="0" cellspacing="0" width="650">
        <thead>
	    <tr height="35px" style="background-color: grey; color: white; font-weight:bold;">
	        <th style="font-size: 16px; padding: 5px; border: solid grey 1px;" align="center" width="325">Return policy</th>
	    </tr>
        </thead>
        <tbody>
	    <tr>
		<div>Returns are accepted within 30 days of shipping, minus a 10% Restocking fee. If more than 30 days has passed a store credit minus a 10% Restocking fee will be issued. For Exchanges no restocking fees will apply.
		<BR><STRONG>NO RETURNS</STRONG> or <STRONG>EXCHANGES</STRONG> on Final Sale or Special Order items.
		<BR>Merchandise must be returned to Bits of Lace in the precise condition it was received, unworn, unwashed, free of perfumes and markings. All original tags and stickers must be in place upon receipt.
		<BR>Please complete Return/Exchange Authorization Form enclosed and return to:<BR><STRONG>Bits of Lace, Attn: Return/Exchanges, 453 West Coleman Blvd, Mt Pleasant, SC 29464.</STRONG>
		<BR>For any questions or concerns contact our Support Team via email or phone at support@bitsoflace.com /800-342-3990
		<BR>To see our full Return Policy, please visit bitsoflace.com/returns-exchanges
		</div>
	    </tr>	    
        </tbody>
    </table>
</div>
%endfor
</body>
</html>


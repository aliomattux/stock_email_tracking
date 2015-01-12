import time
from datetime import datetime
from openerp.osv import osv, fields
from pprint import pprint as pp
from openerp.tools.translate import _
from tzlocal import get_localzone
from lxml import etree
from mako import exceptions
from mako.template import Template


class StockEmailReport(osv.osv_memory):
    _name = 'stock.email.report'


    def render(self, cr, uid, pickings):
        template = Template(filename='/usr/local/openerp/community/stock_email_tracking/report/packing.mako', \
                strict_undefined=True
        )

	functs = {'get_date_created': self._get_date_created,
		  'paginate_items': self._paginate_items,
		  'objects': pickings,
		  'create_tracking_link': self._create_tracking_link,
		  'cr': cr,
	}

        html = template.render(**functs)
	self.send_notification(html, pickings[0])
        return True


    def _create_tracking_link(self, tracking_number):
	if tracking_number[0:2] == '1Z':
	    tracking_number = 'http://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=%s&loc=en_us' % tracking_number
	else:
	    tracking_number = 'https://tools.usps.com/go/TrackConfirmAction.action?tRef=fullpage&tLc=1&text28777=&tLabels=%s' % tracking_number

	return tracking_number


    def send_notification(self, html, picking):
        from email.MIMEMultipart import MIMEMultipart
        from email.MIMEText import MIMEText
        from email.MIMEImage import MIMEImage
        import smtplib
#	current_date = self.current_date()
	invoice_id = picking.sale.partner_invoice_id
	shipping_id = picking.partner_id

	if picking.sale.order_email:
	    email = picking.sale.order_email
	    name = picking.partner_id.name
	elif shipping_id.email:
	    email = shipping_id.email
	    name = shipping_id.name
	elif invoice_id.email:
	    email = invoice_id.email
	    name = invoice_id.name
	else:
	    return False
	    
        sender = 'support@bitsoflace.com'
	receivers = [email]
	msg = MIMEMultipart()
	msg['Subject'] = 'Your Order: %s Has Shipped' % picking.sale.name or picking.name
	msg['From'] = "Customer Service <support@bitsoflace.com>"
	msg['To'] = "%s <%s>" % (name, email)
	body = html
	content = MIMEText(body, 'html')
	msg.attach(content)
        try:
            smtpObj = smtplib.SMTP('localhost')
            smtpObj.sendmail(sender, receivers, msg.as_string())

        except Exception, e:
	    client.captureException()
            print e

	return True


    def _get_date_created(self, picking):
        if picking.create_date and picking.create_date != 'False':
            date_obj = datetime.strptime(picking.create_date, '%Y-%m-%d %H:%M:%S')
            tz = get_localzone()
            dt = tz.localize(date_obj)
            return datetime.strftime(dt, '%m/%d/%Y')

        return ' '


    def get_backorder_qty(self, cr, uid, move):
	query = """SELECT SUM(product_qty) AS "qty" FROM stock_move WHERE split_from = %s AND state != 'done'""" % move.id
	cr.execute(query)
	results = cr.fetchone()
	if results and results[0]:
	    return int(results[0])
	else:
	    return 0


    def prepare_line_val(self, cr, product, move):
	special_order = ' '
	expected_ship_date = ' '
	uid = 1

	for route in product.route_ids:
	    if route.name == 'Make To Order':
	        special_order = 'Yes'
		break

	qty_backorder = self.get_backorder_qty(cr, uid, move) if move.picking_id.state == 'done' else int(move.product_qty)
	if qty_backorder > 0:
	    if move.picking_id.anticipated_ship_date:
		expected_ship_date = move.picking_id.anticipated_ship_date
	    if move.procure_method == 'make_to_order':
		if move.picking_id.anticipated_ship_date:
		    expected_ship_date = move.picking_id.anticipated_ship_date
		else:
		    query = "SELECT id FROM stock_move WHERE purchase_line_id IS NOT NULL AND move_dest_id = %s" % move.id
		    cr.execute(query)
		    result = cr.fetchone()
		    if result and result[0]:
		        po_move = self.pool.get('stock.move').browse(cr, uid, result[0])
		        expected_ship_date = po_move.purchase_line_id.order_id.anticipated_receive_date or ' '

        return {
		'qty_order': int(move.procurement_id.product_qty),
		'qty_ship': int(move.product_qty) if move.picking_id.state == 'done' else 0,
		'qty_backorder': qty_backorder,
		'sku': product.default_code or '',
		'description': product.name or '',
		'special_order': special_order,
		'expected_ship_date': expected_ship_date,
	}


    def _get_components_list(self, cr, line):
	result = []
	for component in line.item.components:
	    result.append(self.prepare_line_val(cr, component.item, component.qty * line.qty))

	return result


    def show_backorder_lines(self, cr, uid, move):
	result = []
        move_obj = self.pool.get('stock.move')
	move_ids = move_obj.search(cr, uid, [('backorder_id', '=', move.picking_id.id)])
	if move_ids:
	   for backorder_move in move_obj.browse(cr, uid, move_ids):
	       result.append(self.prepare_line_val(cr, backorder_move.product_id, backorder_move))

	return result


    def _process_lines(self, cr, uid, lines):
	result = []
        for line in lines:
	    result.append(self.prepare_line_val(cr, line.product_id, line))

	result.extend(self.show_backorder_lines(cr, uid, line))
	return result
#	return sorted(result, key=lambda id: id['prime_location'])


    def _paginate_items(self, cr, lines):

	uid = 1
	processed_lines = self._process_lines(cr, uid, lines)

	return processed_lines


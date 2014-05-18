#!/usr/bin/env python
#coding: utf-8

from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
from json import dumps, loads

items = {
    "0": "吃饭",
    "1": "睡觉",
    "2": "打豆豆"
}
uid = 3

class SimpleRESTRequestHandler(BaseHTTPRequestHandler):

    def receive_id(self):
        id = self.path[1:]
        return id if id in items or id == '' else None

    def send_response(self, *args, **kwargs):
        BaseHTTPRequestHandler.send_response(self, *args, **kwargs)
        if 'Origin' in self.headers:
            self.send_header('Access-Control-Allow-Origin', self.headers['Origin'])
            self.send_header('Access-Control-Allow-Methods', 'OPTIONS, GET, POST, DELETE')
            self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def send_json(self, obj):
        json = dumps(obj)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(json)))
        self.end_headers()
        self.wfile.write(json)

    def do_OPTIONS(self):
        self.send_response(204)
        if self.path != '*': # Not a simple ping
            id = self.receive_id()
            if id == '': # List
                self.send_header('Allow', 'OPTIONS, GET, POST')
            elif id is None: # No item
                self.send_header('Allow', 'OPTIONS')
            else: # Specific one
                self.send_header('Allow', 'OPTIONS, GET, POST, DELETE')

    def do_GET(self):
        global items
        id = self.receive_id()
        if id == '': # Get list
            self.send_response(200)
            self.send_json([{"id": id, "text": text} for (id, text) in items.iteritems()])
        elif id is None: # Not found
            self.send_error(404)
        else: # Get specific one
            self.send_response(200)
            self.send_json({"id": id, "text": items[id]})

    def do_POST(self):
        global items, uid
        id = self.receive_id()
        obj = loads(self.rfile.read(int(self.headers['Content-Length'])))
        if not "text" in obj: # No text field
            self.send_error(403)
        elif id == '': # Create
            newObj = {"id": str(uid), "text": obj["text"]}
            uid += 1
            items[newObj["id"]] = newObj["text"]
            location = 'http://%s/%s' % (self.headers["Host"], newObj["id"])
            self.send_response(201)
            self.send_header('Location', location)
            self.send_header('Content-Location', location)
            self.send_json(newObj)
        elif id is None: # Not exists item
            self.send_error(403)
        else: # Modify
            items[id] = obj["text"]
            self.send_response(204)
            self.end_headers()
    
    def do_DELETE(self):
        global items
        id = self.receive_id()
        if id == '':
            self.send_error(403)
        elif id is None:
            self.send_error(404)
        else:
            del items[id]
            self.send_response(204)
            self.end_headers()

if __name__ == '__main__':

    port = 8000
    print 'Serving on port %d ...' % (port,)
    HTTPServer(('', port), SimpleRESTRequestHandler).serve_forever()

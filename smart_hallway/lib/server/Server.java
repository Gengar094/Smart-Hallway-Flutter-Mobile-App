import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.*;
import java.util.Arrays;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;

public class Server {
    private static String filename = "";
    private static String SETTING_PATH = "config.xml";
    public static void main(String[] args) {
        try {
            ServerSocket ss = new ServerSocket(3000);
            System.out.println("run the server ...");
            Socket s = null;
            while (true) {
                try {
                    s = ss.accept();
                    System.out.println("client has connected ... wait for the command");
                    BufferedReader br = new BufferedReader(new InputStreamReader(s.getInputStream()));
                    String line;
                    while((line = br.readLine()) != null) {
                        System.out.println(line);
                        handleCommand(line, s);
                    }
                    s.close();
                    System.out.println("client has left ...");
                } catch (Exception e) {
                    e.printStackTrace();
                    System.out.println("server error ... ");
                    if (s != null) {
                        OutputStream outputStream = s.getOutputStream();
                        outputStream.write(("an error has occurred, please take a look on the server").getBytes());
                        outputStream.flush();
                        outputStream.close();
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("connection error ...");
            e.printStackTrace();
        }
    }

    private static void handleCommand(String cmd, Socket s) throws Exception{
        System.out.println(cmd);
        if (cmd != null) {
            if (cmd.equals("capture")) {
                capture(s);
            } else if (cmd.startsWith("filename")) {
                String[] ss = cmd.split("\\s+");
                String[] result = Arrays.copyOfRange(ss, 1, ss.length);
                String newStr = String.join(" ", result);
                setFilename(newStr);
                System.out.println("file name has been set to " + filename);
            } else if (cmd.startsWith("set")) {
                String[] ss = cmd.split("\\s+");
                setVideoParameters(ss[1], ss[2]);
            } else {
                end();
            }
        }
    }

    private static void capture(Socket client) throws Exception{
        int counter = 0;
        System.out.println("you have started the capture process ... ");
        Runtime rt = Runtime.getRuntime();

        Process p = rt.exec("./multicamera_capture");
        InputStream inputStream = p.getInputStream();
        OutputStream outputStream = p.getOutputStream();
        InputStream errorStream = p.getErrorStream();
        String line;
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        while ((line = reader.readLine()) != null) {
            System.out.println(line);
            if (line.equals("Provide the name of the trial. [ex: test1] : ")) {
                outputStream.write((filename + "\n").getBytes());
                outputStream.flush();
            }
            if (line.equals("*** CAMERAS READY ***")) {
                if (counter < 3) {
                    counter++;
                    System.out.println(counter);
                } else {
                    System.out.println("program wait");
                    OutputStream out = client.getOutputStream();
                    out.write(("filming is waiting for ending ...").getBytes());
                    out.flush();
                    // out.close();
                    break;
                }
            }
        }
    }

    private static void setVideoParameters(String tag, String value) throws Exception{
        DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();

        try {
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.parse(SETTING_PATH);
            Node node = doc.getElementsByTagName(tag).item(0);
            node.setTextContent(value);

            // Save the changes back to XML file
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            DOMSource source = new DOMSource(doc);
            StreamResult result = new StreamResult(SETTING_PATH);
            transformer.transform(source, result);
        } catch(Exception e) {
            e.printStackTrace();
            throw e;
        } 

    }

    private static void setFilename(String filename) {
        Server.filename = filename;
    }


    private static void end() throws AWTException{
        try {
            System.out.println("end is presseed");
            Robot robot = new Robot();
            // robot.keyPress(KeyEvent.VK_ESCAPE);
            // robot.keyPress(KeyEvent.VK_ENTER);
            // robot.keyRelease(KeyEvent.VK_ENTER);
            // robot.keyRelease(KeyEvent.VK_ESCAPE);
            robot.keyPress(KeyEvent.VK_1);
        } catch (AWTException e) {
            e.printStackTrace();
            throw e;
        }
    }
}
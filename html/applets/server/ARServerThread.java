/*
$Header: /Lessons/util/ARServerThread.java 3     3/02/99 2:00p Lisa $
*/
        /**************************************************************
        *    Copyright (c) 1998 by Pete Boysen                        *
        *             Iowa State University, Ames, IA                 *
        *                                                             *
        * E-Mail: pboysen@iastate.edu                                 *
        * Phone : (515)294-6663                                       *
        *                                                             *
        * Permission to use, copy, and distribute for non-commercial  *
        * purposes, is hereby granted without fee, providing the      *
        * above copyright notice appears in all copies and that both  *
        * the copyright notice and this permission notice appear in   *
        * supporting documentation.                                   *
        *                                                             *
        * THIS PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY    *
        * KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT       *
        * LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND    *
        * FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK AS TO THE *
        * QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.         *
        *                                                             *
        * IN NO EVENT SHALL IOWA STATE UNIVERSITY OR IOWA STATE       *
        * UNIVERSITY RESEARCH FOUNDATION, INC. BE LIABLE TO YOU FOR   *
        * ANY DAMAGES, INCLUDING ANY LOST PROFITS, LOST SAVINGS OR    *
        * OTHER INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING *
        * OUT OF THE USE OR INABILITY TO USE SUCH PROGRAM.            *
        *                                                             *
        **************************************************************/

//package edu.iastate.csl.util;

import java.io.*;
import java.net.*;
import java.awt.*;

public class ARServerThread extends Thread
{

    private String mode = new String("");
    private String filePath = new String("");

    private DataOutputStream output;
    private DataInputStream input;

    private Socket connection;


    public ARServerThread(Socket theConnection)
    {
        connection = theConnection;
    }

    public void run()
    {
        ServerSocket server;

        try {
            output = new DataOutputStream(
                        new BufferedOutputStream(connection.getOutputStream()));
            input = new DataInputStream(
                        new BufferedInputStream(connection.getInputStream()));

            mode = readWord();

            filePath = readWord();

            //System.out.println(mode + " " + filePath);

            if (mode.equalsIgnoreCase("play"))
                play();
            else if (mode.equalsIgnoreCase("record"))
                record();
            else System.out.println("mode is not valid");

            connection.close();
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }

    }

    private void play()
    {
        //System.out.println("in play");

        try
        {
            DataInputStream theFile = new DataInputStream(
                                new FileInputStream(filePath));
            sendData(theFile);
        }
        catch (FileNotFoundException e)
        {
            System.out.println("File was not found");
            try
            {
                output.writeChar('\n');
                return;
            }
            catch (IOException e1)
            {
                e1.printStackTrace();
            }
        }

        catch (IOException e)
        {
            System.out.println("File \"" + filePath + "\" containing session data not opened properly.");
            e.printStackTrace();
        }

    }

    private String readWord()
    {
        String s = "";

        try
        {
            char ch = input.readChar();

            while ((ch == ' '))
            {
                ch = input.readChar();
            }

            while ((ch != ' ') && (ch != '\n'))
            {
                s = s + ch;
                ch = input.readChar();
            }

        }
        catch (IOException e)
        {
            System.out.println("not able to read");
            e.printStackTrace();
        }


        return s;

    }

    private void record()
    {
        //System.out.println("in record");

        try
        {
            RandomAccessFile outFile;
            File oF = new File(filePath);

            if (oF.exists())
            {
                outFile = new RandomAccessFile(filePath,"rw");
                outFile.seek(outFile.length());
            }
            else
            {
                outFile = new RandomAccessFile(filePath,"rw");
            }

            saveData(outFile);
        }
        catch (IOException e)
        {
            System.out.println("File \"" + filePath + "\" for saving session data not opened properly.");
            e.printStackTrace();
        }

    }

    private void saveData(RandomAccessFile o) //DataOutputStream o)
    {
        //System.out.println("in saveData");

        try
        {
            o.writeChars("session " + (new Date()).toString() + '\n');
            char ch = input.readChar();
            while (true)
            {
                o.writeChar(ch);
                ch = input.readChar();
                if (ch == '\n')
                {
                    o.writeChar('\n');
                    ch = input.readChar();
                }

            }

        }
        catch (EOFException e)
        {
            try{ o.close();}
            catch (IOException e1) { e1.printStackTrace(); }
        }

        catch (IOException e)
        {
            System.out.println("problem in saving data");
            e.printStackTrace();
        }

    }

    private void sendData(DataInputStream in)
    {
        //System.out.println("in sendData");
        char ch;

        try
        {
            ch = in.readChar();
            while (true)
            {
                output.writeChar(ch);

                ch = in.readChar();
                if (ch == '\n')
                {
                    output.writeChar('\n');
                    ch = in.readChar();
                }

            }

        }
        catch (EOFException e)
        {
            try
            {
                in.close();
                output.flush();
                output.close();
            }
            catch (IOException e1) { e1.printStackTrace(); }

        }
        catch (IOException e)
        {
            System.out.println("problem in saving data");
            e.printStackTrace();
        }

    }

}

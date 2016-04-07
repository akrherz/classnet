/*
$Header: /Lessons/util/AppletRecorderServer.java 2     11/12/98 7:19p Lisa $
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
import ARServerThread;

public class AppletRecorderServer
{
    public static int SERVER_PORT = 6871;
    public static int NUM_CONNECTIONS = 50;

    private String mode = new String("");
    private String filePath = new String("");

    private DataOutputStream output;
    private DataInputStream input;


    public AppletRecorderServer()
    {
        super();
    }

    public void runServer()
    {
        ServerSocket server;
        Socket connection;

        try
        {
            server = new ServerSocket(SERVER_PORT, NUM_CONNECTIONS);

            while (true)
            {
                connection = server.accept();

                (new ARServerThread(connection)).start();
            }

        }
        catch (IOException e)
        {
            e.printStackTrace();
        }

    }

    public static void main( String args[] )
    {
        AppletRecorderServer ars = new AppletRecorderServer();

        ars.runServer();

    }

}
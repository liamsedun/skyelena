import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*',
    credentials: true,
  },
  namespace: '/ws',
})
export class WebsocketGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private userSockets: Map<string, string[]> = new Map();

  handleConnection(client: Socket) {
    const userId = client.handshake.query.userId as string;
    if (userId) {
      const sockets = this.userSockets.get(userId) || [];
      sockets.push(client.id);
      this.userSockets.set(userId, sockets);
    }
  }

  handleDisconnect(client: Socket) {
    const userId = client.handshake.query.userId as string;
    if (userId) {
      const sockets = this.userSockets.get(userId) || [];
      this.userSockets.set(
        userId,
        sockets.filter((s) => s !== client.id),
      );
    }
  }

  sendToUser(userId: string, event: string, data: any) {
    const sockets = this.userSockets.get(userId) || [];
    sockets.forEach((socketId) => {
      this.server.to(socketId).emit(event, data);
    });
  }

  @SubscribeMessage('join')
  handleJoin(client: Socket, userId: string) {
    const sockets = this.userSockets.get(userId) || [];
    if (!sockets.includes(client.id)) {
      sockets.push(client.id);
      this.userSockets.set(userId, sockets);
    }
    return { event: 'joined', data: { userId } };
  }
}

import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { MessagesService } from './messages.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { SendMessageDto } from './dto/send-message.dto';

@Controller('messages')
@UseGuards(JwtAuthGuard)
export class MessagesController {
  constructor(private messagesService: MessagesService) {}

  @Get()
  findAll(@CurrentUser() user: any) {
    return this.messagesService.findAll(user.id);
  }

  @Get('conversations')
  getConversations(@CurrentUser() user: any) {
    return this.messagesService.findConversations(user.id);
  }

  @Get('conversations/:id')
  getConversation(@Param('id') id: string) {
    return this.messagesService.findByConversation(id);
  }

  @Post('send')
  send(@CurrentUser() user: any, @Body() dto: SendMessageDto) {
    return this.messagesService.send(user.id, dto);
  }
}

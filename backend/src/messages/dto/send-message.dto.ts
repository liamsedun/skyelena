import { IsString, IsOptional } from 'class-validator';

export class SendMessageDto {
  @IsString()
  channel: string;

  @IsString()
  toNumber: string;

  @IsString()
  content: string;

  @IsOptional()
  @IsString()
  conversationId?: string;
}

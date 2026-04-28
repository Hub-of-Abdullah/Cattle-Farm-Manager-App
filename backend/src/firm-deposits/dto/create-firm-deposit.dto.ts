import { IsNumber, IsDateString, IsOptional, IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateFirmDepositDto {
  @ApiProperty({ example: 20000, description: 'Negative value for withdrawal' })
  @IsNumber()
  @IsNotEmpty()
  amount: number;

  @ApiProperty({ example: '2026-04-28' })
  @IsDateString()
  date: string;

  @ApiPropertyOptional({ example: 'Capital injection' })
  @IsOptional()
  @IsString()
  note?: string;
}
